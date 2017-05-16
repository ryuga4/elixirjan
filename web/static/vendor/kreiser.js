/**
 * Created by me on 16.05.17.
 */
PopulateSelectors();
function PopulateSelectors()
{
    for (i = 1950; i < 2017; i++) {
        $('#wrapper_year > .selector_content').prepend('<button class="option">' + i + '</button>');
    }

    for (i = 1; i < 32; i++) {
        if (i >= 10) {
            $('#wrapper_day > .selector_content').append('<button class="option">' + i + '</button>');
        }
        else {
            $('#wrapper_day > .selector_content').append('<button class="option">0' + i + '</button>');
        }
    }

    for (i = 1; i < 13; i++) {
        if (i >= 10) {
            $('#wrapper_month > .selector_content').append('<button class="option">' + i + '</button>');
        }
        else {
            $('#wrapper_month > .selector_content').append('<button class="option">0' + i + '</button>');
        }
    }

    for (i = 4; i < 13; i++) {
        $('#wrapper_sleep > .selector_content').append('<button class="option">' + i + '</button>');
    }
}


var clicked = [true, false, false];

$('#leftbutton').click(function ()
{
    ClickFunction(0);
});

$('#midbutton').click(function () {
    ClickFunction(1);
});

$('#rightbutton').click(function () {
    ClickFunction(2);
});

function ClickFunction(which)
{
    switch(which)
    {
        case 0:
            if (clicked[which] == false) {
                clicked[1] = false;
                clicked[2] = false;
                $('#leftbutton').addClass("mainbutton_pressed");
                $('#midbutton').removeClass("mainbutton_pressed");
                $('#rightbutton').removeClass("mainbutton_pressed");
                clicked[which] = !clicked[which];
                $('#zone_about').addClass("no_display");
                $('#zone_explore').addClass("no_display");
                $('#zone_calculator').removeClass("no_display");
            }

            break;
        case 1:
            if (clicked[which] == false) {
                clicked[0] = false;
                clicked[2] = false;
                $('#midbutton').addClass("mainbutton_pressed");
                $('#leftbutton').removeClass("mainbutton_pressed");
                $('#rightbutton').removeClass("mainbutton_pressed");
                clicked[which] = !clicked[which];
                $('#zone_calculator').addClass("no_display");
                $('#zone_explore').addClass("no_display");
                $('#zone_about').removeClass("no_display");
            }
            break;
        case 2:
            if (clicked[which] == false) {
                clicked[0] = false;
                clicked[1] = false;
                $('#rightbutton').addClass("mainbutton_pressed");
                $('#leftbutton').removeClass("mainbutton_pressed");
                $('#midbutton').removeClass("mainbutton_pressed");
                clicked[which] = !clicked[which];
                $('#zone_calculator').addClass("no_display");
                $('#zone_about').addClass("no_display");
                $('#zone_explore').removeClass("no_display");
            }
            break;
        default:
            break;
    }

}

$('#day_select').click(function () {
    $('#wrapper_day > .selector_content').toggleClass("no_display");
});

$('#month_select').click(function () {
    $('#wrapper_month > .selector_content').toggleClass("no_display");
});

$('#year_select').click(function () {
    $('#wrapper_year > .selector_content').toggleClass("no_display");
});

$('#life_select').click(function () {
    $('#wrapper_life > .selector_content').toggleClass("no_display");
});

$('#sleep_select').click(function () {
    $('#wrapper_sleep > .selector_content').toggleClass("no_display");
});

//============= INPUT HANDLING =============
var b_day = "00";
var b_month = "00";
var b_year = "0000";
var lifespan = 0;
var sleep = 0;
$('#wrapper_day > .selector_content > .option').click(function () {
    b_day = $(this).text();
    $('#day_select').html(b_day);
    $('#wrapper_day > .selector_content').addClass("no_display");
});

$('#wrapper_month > .selector_content > .option').click(function () {
    b_month = $(this).text();
    $('#month_select').html(b_month);
    $('#wrapper_month > .selector_content').addClass("no_display");
});

$('#wrapper_year > .selector_content > .option').click(function () {
    b_year = $(this).text();
    $('#year_select').html(b_year);
    $('#wrapper_year > .selector_content').addClass("no_display");
});

$('#wrapper_life > .selector_content > .option').click(function () {
    lifespan = $(this).text().substring(0, 3);
    lifespan = lifespan.replace(/\s+/g, '');
    lifespan = parseInt(lifespan, 10);
    $('#life_select').html(lifespan);
    $('#wrapper_life > .selector_content').addClass("no_display");
});

$('#wrapper_sleep > .selector_content > .option').click(function () {
    sleep = parseInt($(this).text(),10);
    $('#sleep_select').html(sleep);
    $('#wrapper_sleep > .selector_content').addClass("no_display");
});

var counter = 1;
var sleep_days = 0;
var slept_days = 0;
var lived_days = 0;
var future_sleep_contr = 0;
var days = 0;
var one_day = 24 * 60 * 60 * 1000;
var controller = true;
//================= ACTUAL CALCULATION =================
$('#calculate_button').click(function () {
    if((b_day == "00" || b_month == "00" || b_year == "0000" || lifespan == 0 || sleep == 0)
        || ((b_month == "04" || b_month == "06" || b_month == "09" || b_month == "11") && b_day == "31")
        || (b_month == "02" && parseInt(b_day, 10) > 29)
        || (IsLeapYear(parseInt(b_year,10)) == false && b_month == "02" && b_day == "29"))
    {
        //invalid info
        $('#alert_data').removeClass("transparent_text");
    }
    else
    {
        var current_date = new Date();
        current_date.setHours(0, 0, 0, 0);
        var birthday = new Date(b_year + "-" + b_month + "-" + b_day);
        b_year = parseInt(b_year, 10);
        var future_date = new Date((b_year + lifespan) + "-" + b_month + "-" + b_day);

        days = Math.round(Math.abs((future_date.getTime() - birthday.getTime()) / (one_day)));
        lived_days = Math.round(Math.abs((current_date.getTime() - birthday.getTime()) / (one_day)));
        sleep_days = Math.round((days - lived_days) * sleep / 24);
        slept_days = Math.round(lived_days * sleep / 24);
        future_sleep_contr = sleep_days + lived_days;
        setTimeout("HideCalcu()", 75);
        setTimeout("SpawnCapsules()", 100);
    }
});

function HideCalcu()
{
    counter = 1;
    $('#zone_calculator').addClass("no_display");
    $('#main_buttonbar').addClass("no_display");
    $('#zone_capsules').removeClass("no_display");
}

function SpawnCapsules()
{
    controller = true;
    while (controller == true)
    {
        if(counter <= days)
        {

            if (counter <= lived_days)
            {
                if (counter <= slept_days)
                {
                    $('#zone_capsules > .capsule_row:last').append('<div class="capsule slept"></div>');
                }
                else
                {
                    $('#zone_capsules > .capsule_row:last').append('<div class="capsule lived"></div>');
                }
            }
            else
            {
                if(counter > lived_days && counter <= (future_sleep_contr))
                {
                    $('#zone_capsules > .capsule_row:last').append('<div class="capsule sleep"></div>');
                }
                else
                {
                    $('#zone_capsules > .capsule_row:last').append('<div class="capsule"></div>');
                }
            }

            if (counter % 365 == 0)
            {
                //new line
                $('#zone_capsules').append('<div class="capsule_row"></div>');
                controller = false;
                setTimeout("SpawnCapsules()", 20);
            }
            if (counter == days)
            {
                controller = false;
            }
            counter += 1;
        }
    }
}

function IsLeapYear(year)
{
    return ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
}