package cl.iplacex.automatizacion.web;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

import static org.junit.jupiter.api.Assertions.assertTrue;

class SeleniumSmokeTest {

    private static final String FORMULARIO_SELENIUM =
            "https://www.selenium.dev/selenium/web/web-form.html";

    private WebDriver driver;
    private WebDriverWait espera;

    @BeforeEach
    void abrirNavegador() {
        driver = WebDriverFactory.crearChrome();
        espera = new WebDriverWait(driver, Duration.ofSeconds(10));
    }

    @AfterEach
    void cerrarNavegador() {
        if (driver != null) {
            driver.quit();
        }
    }

    @Test
    void cargaElFormularioDeEjemploDeSelenium() {
        driver.get(FORMULARIO_SELENIUM);

        WebElement titulo = espera.until(
                ExpectedConditions.visibilityOfElementLocated(By.tagName("h1")));

        assertTrue(titulo.getText().contains("Web form"),
                "La página de ejemplo de Selenium no cargó el formulario");
    }
}
