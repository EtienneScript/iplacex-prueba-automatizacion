package cl.iplacex.automatizacion.web;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;

/**
 * Crea instancias de WebDriver. Selenium Manager descarga el driver.
 */
public final class WebDriverFactory {

    private WebDriverFactory() {
    }

    public static WebDriver crearChrome() {
        ChromeOptions options = new ChromeOptions();
        if (Boolean.parseBoolean(System.getProperty("headless", "true"))) {
            options.addArguments("--headless=new");
        }
        options.addArguments("--disable-gpu");
        options.addArguments("--no-sandbox");
        options.addArguments("--disable-dev-shm-usage");
        options.addArguments("--window-size=1280,720");
        return new ChromeDriver(options);
    }
}
