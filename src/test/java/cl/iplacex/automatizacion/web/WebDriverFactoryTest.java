package cl.iplacex.automatizacion.web;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.chrome.ChromeOptions;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

@Tag("unitaria")
class WebDriverFactoryTest {

    @AfterEach
    void limpiarPropiedadHeadless() {
        System.clearProperty("headless");
    }

    @Test
    void activaHeadlessPorDefecto() {
        List<String> args = argumentos(WebDriverFactory.crearOpciones());

        assertTrue(args.contains("--headless=new"));
        assertTrue(args.contains("--no-sandbox"));
        assertTrue(args.contains("--window-size=1280,720"));
    }

    @Test
    void permiteDesactivarHeadless() {
        System.setProperty("headless", "false");

        List<String> args = argumentos(WebDriverFactory.crearOpciones());

        assertFalse(args.contains("--headless=new"));
    }

    @SuppressWarnings("unchecked")
    private static List<String> argumentos(ChromeOptions options) {
        Object chrome = options.getCapability(ChromeOptions.CAPABILITY);
        if (chrome instanceof Map<?, ?> config && config.get("args") instanceof List<?> args) {
            return args.stream().map(String::valueOf).toList();
        }
        return List.of();
    }
}
