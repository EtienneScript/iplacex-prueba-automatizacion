package cl.iplacex.automatizacion;

import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;

@Tag("unitaria")
class SanityTest {

    @Test
    void elEntornoDePruebasEstaListo() {
        assertTrue(Runtime.version().feature() >= 17, "Se requiere Java 17 o superior");
    }
}
