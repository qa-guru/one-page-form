package tests;
import com.codeborne.selenide.Configuration;
import com.codeborne.selenide.logevents.SelenideLogger;

import config.ConfigReader;
import config.TestConfig;

import io.qameta.allure.selenide.AllureSelenide;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;

import static com.codeborne.selenide.Selenide.closeWebDriver;

public class TestBase {

    @BeforeAll
    static void setup() {
        SelenideLogger.addListener("AllureSelenide",
                new AllureSelenide()
                        .screenshots(true)
                        .savePageSource(true));

        TestConfig config = ConfigReader.config;

        Configuration.baseUrl = ConfigReader.resolvedBaseUrl();
        Configuration.browser = config.browser();
        Configuration.browserSize = config.browserSize();
        Configuration.headless = config.headless();
    }

    @AfterEach
    void afterEach() {
        closeWebDriver();
    }
}
