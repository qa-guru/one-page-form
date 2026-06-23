package tests;

import helpers.Attachments;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import com.codeborne.selenide.logevents.SelenideLogger;
import io.qameta.allure.selenide.AllureSelenide;
import com.codeborne.selenide.Configuration;
import org.openqa.selenium.chrome.ChromeOptions;
import config.ConfigReader;
import static com.codeborne.selenide.Selenide.closeWebDriver;
import static config.ConfigReader.resolvedBaseUrl;


public class TestBase {

    @BeforeAll
    static void setup() {
        SelenideLogger.addListener("AllureSelenide",
        new AllureSelenide()
                .screenshots(true)
                .savePageSource(false));
    
        var config = ConfigReader.config;
    
        Configuration.baseUrl = resolvedBaseUrl();
        Configuration.browser = config.browser();
        Configuration.browserSize = config.browserSize();
        Configuration.headless = config.headless();
    
        if (config.headless()) {
          Configuration.browserCapabilities = new ChromeOptions()
              .addArguments("--disable-gpu", "--no-sandbox", "--disable-dev-shm-usage");
        }
    }

    @AfterEach
    void afterEach() {
        Attachments.screenshotAs("Last screenshot");
        closeWebDriver();
    }
}
