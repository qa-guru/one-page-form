import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static com.codeborne.selenide.Condition.*;
import static com.codeborne.selenide.Selectors.byText;
import static com.codeborne.selenide.Selenide.*;

public class RegistrationTests extends TestBase {

    @Test
    void successfulRegistrationTest() {
        open("/automation-practice-form.html");
        $(".practice-form-wrapper").shouldHave(text("Student Registration Form"));
        executeJavaScript("$('#fixedban').remove()");
        executeJavaScript("$('footer').remove()");

        $("#firstName").setValue("Alex");
        $("#lastName").setValue("Egorov");
        $("#userEmail").setValue("alex@egorov.com");
        $("#genterWrapper").$(byText("Other")).click();
        $("#userNumber").setValue("1234567890");
        $("#dateOfBirthInput").click();
        $(".react-datepicker__month-select").selectOption("July");
        $(".react-datepicker__year-select").selectOption("2008");
        $(".react-datepicker__day--030:not(.react-datepicker__day--outside-month)").click();
        $("#subjectsInput").setValue("Math").pressEnter();
        $("#hobbiesWrapper").$(byText("Sports")).click();
        $("#uploadPicture").uploadFromClasspath("img/1.png");
        $("#currentAddress").setValue("Some address 1");
        $("#state").click();
        $("#stateCity-wrapper").$(byText("NCR")).click();
        $("#city").click();
        $("#stateCity-wrapper").$(byText("Delhi")).click();
        $("#submit").click();

        $(".modal-dialog").should(appear);
        $("#example-modal-sizes-title-lg").shouldHave(text("Thanks for submitting the form"));
        $(".table-responsive")
                .shouldHave(text("Alex"), text("Egorov"),
                        text("alex@egorov.com"), text("1234567890"));
    }
    @Test
    void successfulRegistrationTest_demoqa() {
        open("https://demoqa.com/automation-practice-form");
        $(".practice-form-wrapper").shouldHave(text("Student Registration Form"));
//        executeJavaScript("$('#fixedban').remove()");
//        executeJavaScript("$('footer').remove()");

        $("#firstName").setValue("Alex");
        $("#lastName").setValue("Egorov");
        $("#userEmail").setValue("alex@egorov.com");
        $("#genterWrapper").$(byText("Other")).click();
        $("#userNumber").setValue("1234567890");
        $("#dateOfBirthInput").click();
        $(".react-datepicker__month-select").selectOption("July");
        $(".react-datepicker__year-select").selectOption("2008");
        $(".react-datepicker__day--030:not(.react-datepicker__day--outside-month)").click();
        $("#subjectsInput").setValue("Math").pressEnter();
        $("#hobbiesWrapper").$(byText("Sports")).click();
        $("#uploadPicture").uploadFromClasspath("img/1.png");
        $("#currentAddress").setValue("Some address 1");
        $("#state").click();
        $("#stateCity-wrapper").$(byText("NCR")).click();
        $("#city").click();
        $("#stateCity-wrapper").$(byText("Delhi")).click();
        $("#submit").click();

        $(".modal-dialog").should(appear);
        $("#example-modal-sizes-title-lg").shouldHave(text("Thanks for submitting the form"));
        $(".table-responsive")
                .shouldHave(text("Alex"), text("Egorov"),
                        text("alex@egorov.com"), text("1234567890"));
    }

    int month;
    int year;
    int day = LocalDate.now().getDayOfMonth();

    {
        month = LocalDate.now().getMonthValue();
        year =  LocalDate.now().getYear();
    }


    @Test
    void fillAllFieldsAndSubmitTest_Igor() {
        open("/automation-practice-form.html");
        executeJavaScript("$('#fixedban').remove()");
        executeJavaScript("$('footer').remove()");

        $("#firstName").setValue("John");
        $("#lastName").setValue("Doe");
        $("#userEmail").setValue("john.doe@example.com");

        $("#genterWrapper").$$("label").findBy(text("Male")).click();

        $("#userNumber").setValue("1234567890");

        $("[id=dateOfBirthInput]").click();
        $(".react-datepicker__month-select").selectOption(month - 1);
        $(".react-datepicker__year-select").selectOption(String.valueOf(year - 10));
        String dayFormatted = String.format("%03d", day);
        $(".react-datepicker__day--" + dayFormatted + ":not(.react-datepicker__day--outside-month)").click();

        $("#subjectsInput").click();
        $("#subjectsInput").setValue("English");
        $(".subjects-auto-complete__option").click();

        $("[id=hobbies-checkbox-1]").click();

        $("#uploadPicture").uploadFromClasspath("img/1.png");

        $("#currentAddress").setValue("123 Main Street, New York");

        $("#state").click();
        $("#stateCity-wrapper").$(byText("Uttar Pradesh")).click();
        $("#city").click();
        $("#stateCity-wrapper").$(byText("Agra")).click();

        $("#submit").click();

        $(".modal-dialog").shouldBe(visible);
        $(".table-responsive").shouldHave(text("Student Name"));
        $(".table-responsive").shouldHave(text("John Doe"));
        $(".table-responsive").shouldHave(text("john.doe@example.com"));
        $(".table-responsive").shouldHave(text("Male"));
        $(".table-responsive").shouldHave(text("1234567890"));
        $(".table-responsive").shouldHave(text("English"));
        $(".table-responsive").shouldHave(text("Sports"));
        $(".table-responsive").shouldHave(text("123 Main Street, New York"));
        $(".table-responsive").shouldHave(text("Uttar Pradesh"));
        $(".table-responsive").shouldHave(text("Agra"));
    }
}
