package cl.iplacex.automatizacion.web;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

import static org.junit.jupiter.api.Assertions.assertEquals;

@Tag("aceptacion")
class FormularioAceptacionAT {

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
    void elUsuarioPuedeEnviarElFormularioYRecibirConfirmacion() {
        driver.get(FORMULARIO_SELENIUM);

        WebElement campoTexto = espera.until(
                ExpectedConditions.visibilityOfElementLocated(By.name("my-text")));
        campoTexto.sendKeys("Iplacex");
        driver.findElement(By.cssSelector("button")).click();

        WebElement mensaje = espera.until(
                ExpectedConditions.visibilityOfElementLocated(By.id("message")));

        assertEquals("Received!", mensaje.getText(),
                "El criterio de aceptación es confirmar el envío del formulario");
    }
}
