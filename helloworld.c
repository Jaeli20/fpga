#include "xparameters.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "sleep.h"

// ==================================================================
// CONFIGURACIÓN DE DISPOSITIVOS
// ==================================================================
#define GPIO_FLEX_ID XPAR_AXI_GPIO_0_DEVICE_ID   // 5 sensores flex
#define GPIO_BTN_ID  XPAR_AXI_GPIO_1_DEVICE_ID   // 4 botones
#define GPIO_CH      1
#define NUM_FLEX     5

// ==================================================================
// MAPEO DE SEÑAS (5 flex + 1 botón movimiento)
// ==================================================================
typedef struct {
    u8 pattern;    // bits de los 5 sensores flex (P I M A Mq)
    u8 move;       // 1 = requiere modo movimiento activo, 0 = normal
    char letter;   // letra asociada
} SignMap;

const SignMap static_signs[] = {
    {0b00001, 0, 'A'}, {0b11110, 0, 'B'}, {0b00011, 0, 'L'},
    {0b00010, 0, 'D'}, {0b00111, 0, 'H'}, {0b10100, 0, 'I'},
    {0b10001, 0, 'Y'}, {0b00000, 0, 'T'}, {0b00110, 0, 'U'},
    {0b01110, 0, 'W'}, {0b00101, 0, 'R'}, {0b11111, 0, 'C'},
	{0b11101, 0, 'F'}, {0b11001, 0, 'O'},
    // Con movimiento activado
    {0b10000, 1, 'I'}, {0b00010, 1, 'Z'}, {0b00110, 1, 'N'},
    {0b00011, 1, 'G'}, {0b00000, 1, 'M'}, {0b00010, 1, 'K'},
    {0b00111, 1, 'P'}, {0b00101, 1, 'E'},
};
#define NUM_SIGNS (sizeof(static_signs)/sizeof(static_signs[0]))

const char* finger_names[NUM_FLEX] = {
    "Pulgar", "Indice", "Medio", "Anular", "Meñique"
};

#define MAX_WORD_LEN 64   // ahora puede almacenar más letras

int main() {
    XGpio gpio_flex, gpio_btn;
    int status;
    u32 raw_flex, raw_btn;
    u8 pattern = 0;
    u8 move_mode = 0; // Estado persistente del modo de movimiento
    char current_letter = '?';
    char last_letter = '?';
    char word[MAX_WORD_LEN + 1] = "";
    int word_len = 0;

    xil_printf("\033[2J");
    xil_printf("=====================================================\r\n");
    xil_printf("   GUANTE FPGA + BOTONES DE CONTROL (Zybo Z7)\r\n");
    xil_printf("=====================================================\r\n\r\n");

    status = XGpio_Initialize(&gpio_flex, GPIO_FLEX_ID);
    if (status != XST_SUCCESS) {
        xil_printf("❌ Error: no se pudo inicializar GPIO FLEX\r\n");
        return XST_FAILURE;
    }
    status = XGpio_Initialize(&gpio_btn, GPIO_BTN_ID);
    if (status != XST_SUCCESS) {
        xil_printf("❌ Error: no se pudo inicializar GPIO BOTONES\r\n");
        return XST_FAILURE;
    }

    XGpio_SetDataDirection(&gpio_flex, GPIO_CH, 0xFFFFFFFF);
    XGpio_SetDataDirection(&gpio_btn, GPIO_CH, 0xFFFFFFFF);

    u8 prev_btn_state = 0xFF;

    while (1) {
        raw_flex = XGpio_DiscreteRead(&gpio_flex, GPIO_CH) & 0x1F;
        raw_btn  = XGpio_DiscreteRead(&gpio_btn, GPIO_CH) & 0x0F;

        pattern = (u8)raw_flex;

        u8 btn_move    = ((raw_btn & 0x01) == 0); // BTN0 toggle movimiento
        u8 btn_confirm = ((raw_btn & 0x02) == 0); // BTN1 confirmar
        u8 btn_show    = ((raw_btn & 0x04) == 0); // BTN2 mostrar palabra

        // ======================================================
        // TOGGLE de movimiento persistente (solo cambia al presionar)
        // ======================================================
        if (btn_move && ((prev_btn_state & 0x01) != 0)) {
            move_mode = !move_mode;
            xil_printf("\r\n🌀 Modo movimiento %s\r\n",
                       move_mode ? "ACTIVADO ✅" : "DESACTIVADO ❌");
        }

        // Buscar letra según modo actual
        char new_letter = '?';
        for (int i = 0; i < NUM_SIGNS; i++) {
            if (pattern == static_signs[i].pattern &&
                move_mode == static_signs[i].move) {
                new_letter = static_signs[i].letter;
                break;
            }
        }
        current_letter = (new_letter != '?') ? new_letter : ' ';

        // Detectar cambios de letra
        if (current_letter != last_letter) {
            xil_printf("\r\n🆕 Nueva letra detectada: %c\r\n", current_letter);
            last_letter = current_letter;
        }

        xil_printf("\033[H");
        xil_printf("=====================================================\r\n");
        xil_printf(" FLEX Y BOTONES\r\n");
        xil_printf("=====================================================\r\n");

        for (int i = 0; i < NUM_FLEX; i++) {
            u8 bit = (pattern >> i) & 1;
            xil_printf(" %-8s → %s\r\n", finger_names[i],
                       bit ? "LIBRE   " : "DOBLADO ");
        }

        xil_printf("\r\n MODO MOVIMIENTO : %s\r\n", move_mode ? "ACTIVO ✅" : "INACTIVO ❌");
        xil_printf(" BTN1 (confirmar):  %s\r\n", btn_confirm ? "PRESIONADO" : "LIBRE");
        xil_printf(" BTN2 (mostrar):    %s\r\n", btn_show ? "PRESIONADO" : "LIBRE");
        xil_printf("-----------------------------------------------------\r\n");
        xil_printf(" Letra actual     : %c\r\n", current_letter);
        xil_printf(" Palabra parcial  : %s\r\n", word);
        xil_printf("=====================================================\r\n");

        // ======================================================
        // CONFIRMAR LETRA
        // ======================================================
        if (btn_confirm && ((prev_btn_state & 0x02) != 0)) {
            if (current_letter != ' ' && word_len < MAX_WORD_LEN) {
                word[word_len++] = current_letter;
                word[word_len] = '\0';
                xil_printf("✅ Letra '%c' agregada a palabra.\r\n", current_letter);
            } else {
                xil_printf("⚠️ No se agregó letra (espacio o límite alcanzado)\r\n");
            }
        }

        // ======================================================
        // MOSTRAR Y LIMPIAR SOLO LA PALABRA
        // ======================================================
        if (btn_show && ((prev_btn_state & 0x04) != 0)) {
            xil_printf("\r\n=========================================\r\n");
            xil_printf(" PALABRA FORMADA: %s\r\n", word_len > 0 ? word : "(vacía)");
            xil_printf("=========================================\r\n\n\r"); // 👈 salto doble
            sleep(2); // muestra 2 segundos la palabra
            xil_printf("🔄 Palabra reiniciada, lista para nueva entrada.\r\n\n");
            word_len = 0;
            word[0] = '\0';
        }

        prev_btn_state = raw_btn;
        usleep(200000);
    }

    return XST_SUCCESS;
}
