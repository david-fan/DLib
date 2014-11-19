package org.david.util {
/**
 * 日期时间工具类
 */
public class DateTimeUtil {
    private static var _serverDate:Date = new Date();

    public static function get ServerDate():Date {
        return _serverDate;
    }

    public static function set ServerDate(value:Date):void {
        _serverDate = value;
    }

    public static const MILLISECOND:Number = 1;
    public static const SECOND:Number = MILLISECOND * 1000;
    public static const MINUTE:Number = SECOND * 60;
    public static const HOUR:Number = MINUTE * 60;
    public static const DAY:Number = HOUR * 24;
    public static const WEEK:Number = DAY * 7;
    public static const CHINESE_DATE_FORMAT:String = "YYYY-MM-DD";
    public static const CHINESE_DATETIME_FORMAT:String = "YYYY-MM-DD";

    /**
     * 给制定时间添加天数或减少天数
     *
     */
    public static function addDays(date:Date, addDays:int):void {
        date.setTime(date.getTime() + addDays * DAY);
    }

    public static function addSeconds(date:Date, addSecond:int):void {
        var time:Number = date.getTime() + addSecond * SECOND;
        date.setTime(time);
        // trace("add second:" + date.toString());
    }

    /**
     * {hour:0,minute:0,seconds:0}
     */
    public static function getTimeObj(time:int):Object {
        var hour:* = int(time / HOUR);
        var minute:* = int(time % HOUR / MINUTE);
        var secounds:* = int(time % HOUR % MINUTE / SECOND);
        var timeobj:Object = {};
        timeobj.hour = "" + hour;
        timeobj.minute = "" + minute;
        timeobj.seconds = "" + secounds;
        return timeobj;
    }

    /**
     * 格式化毫秒为时间字符串
     * @param    time    毫秒
     * @return 00:00:00
     */

    public static function getFormatTimeStr(time:Number):String {
        var h:int = int(time / HOUR);
        var m:int = int(time % HOUR / MINUTE);
        var s:int = int(time % HOUR % MINUTE / SECOND);
        var timestr:String = formartNumber(h) + ":" + formartNumber(m) + ":" + formartNumber(s);
        return timestr;
    }

    /**
     * 根据00:00:00字符串，返回毫秒数
     * @param    str
     * @return
     */

    public static function getTimeFromStr(str:String):Number {
        var temp:Array = str.split(":");
        var t:Number = HOUR * int(temp[0]) + MINUTE * int(temp[1]) + SECOND * int(temp[2]);
        return t;
    }

    /**
     * 格式：20120101010101
     * @param date
     * @return
     */
    public static function getDateStr(date:Date):String {
        return "" + date.fullYear + formartNumber(date.month + 1) + formartNumber(date.date) + formartNumber(date.hours) + formartNumber(date.minutes) + formartNumber(date.seconds);
    }

    public static function formartNumber(num:int):String {
        if (num < 10)
            return "0" + num;
        else
            return num.toString();
    }

    /**
     * 取下一天
     */
    public static function getNextDay(currentDate:Date):void {
        addDays(currentDate, 1);
    }

    /**
     * 取上一天
     */
    public static function getLastDay(currentDate:Date):void {
        addDays(currentDate, -1);
    }

    /**
     * 取下一个月
     */
    public static function getNextMonth(currentDate:Date):Date {
        var returnDate:Date = new Date(currentDate.getTime());
        returnDate.setMonth(returnDate.getMonth() + 1, returnDate.getDate());
        return returnDate;
    }

    /**
     * 取上一个月
     */
    public static function getLastMonth(currentDate:Date):Date {
        var returnDate:Date = new Date(currentDate.getTime());
        returnDate.setMonth(returnDate.getMonth() - 1, returnDate.getDate());
        return returnDate;
    }

    /**
     * 取下一个年
     */
    public static function getNextYear(currentDate:Date):Date {
        var returnDate:Date = new Date(currentDate.getTime());
        returnDate.setFullYear(returnDate.getFullYear() + 1);
        return returnDate;
    }

    /**
     * 取上一个年
     */
    public static function getLastYear(currentDate:Date):Date {
        var returnDate:Date = new Date(currentDate.getTime());
        returnDate.setFullYear(returnDate.getFullYear() - 1);
        return returnDate;
    }

    /**
     * 取当月月底
     */
    public static function getFristDayOfMonth(currentDate:Date):Date {
        currentDate.setMonth(currentDate.getMonth(), 1);
        // 下个月的第一天，也就是下个月1号
        return currentDate;
    }

    /**
     * 取当月月底
     */
    public static function getLastDayOfMonth(currentDate:Date):Date {
        currentDate.setMonth(currentDate.getMonth() + 1, 1);
        // 下个月的第一天，也就是下个月1号
        currentDate.setDate(currentDate.getDate() - 1);
        // 下个月1号之前1天，也就是本月月底
        return currentDate;
    }

    /**
     * 格式: 2009/12/11 09:00:00
     */
    public static function getDateString(date:Date, hasDateStr:Boolean = true):String {
        var dYear:String = String(date.getFullYear());

        var dMouth:String = String((date.getMonth() + 1 < 10) ? "0" : "") + (date.getMonth() + 1);

        var dDate:String = ((date.getDate() < 10) ? "0" : "") + date.getDate();

        var ret:String = "";

        if (hasDateStr)
            ret += dYear + "/" + dMouth + "/" + dDate + " ";

        // ret += DAYS[date.getDay()] + "";

        ret += ((date.getHours() < 10) ? "0" : "") + date.getHours() + ":";

        ret += ((date.getMinutes() < 10) ? "0" : "") + date.getMinutes() + ":";

        ret += ((date.getSeconds() < 10) ? "0" : "") + date.getSeconds();
        // 想要获取秒的话，date.getSeconds() ，语句同小时、分

        return ret;
    }

    /**
     * 获取日期的中文表示方式(0表示星期天)
     * @param currentDate
     * @return
     */
    public static function getChineseDay(currentDate:Date):String {
        switch (currentDate.getDay()) {
            case 0:
                return "星期日";
            case 1:
                return "星期一";
            case 2:
                return "星期二";
            case 3:
                return "星期三";
            case 4:
                return "星期四";
            case 5:
                return "星期五";
            case 6:
                return "星期六";
            default:
                return "";
        }
    }

    /**
     * 获取日期的英文表示方式(0表示星期天)
     * @param currentDate
     * @return
     */
    public static function getEnglishDay(currentDate:Date):String {
        switch (currentDate.getDay()) {
            case 0:
                return "Sunday";
            case 1:
                return "Monday";
            case 2:
                return "Tuesday";
            case 3:
                return "Wednesday";
            case 4:
                return "Thursday";
            case 5:
                return "Friday";
            case 6:
                return "Saturday";
            default:
                return "";
        }
    }

    public static function getDateByMinute(minute:int):Date {
        return new Date(null, null, null, null, minute);
    }

    public static function getTotalMinute(date:Date):int {
        return date.day * 24 * 60 + date.hours * 60 + date.minutes;
    }

    public static function getMinuteBetween(start:Date, end:Date):int {
        return (end.getTime() - start.getTime()) / (1000 * 60);
    }

    public static function getSecondBetween(start:Date, end:Date):int {
        return (end.getTime() - start.getTime()) / 1000;
    }

    public static function getHourBetween(start:Date, end:Date):int {
        return (end.getTime() - start.getTime()) / (1000 * 60 * 60);
    }

    public static function getBetween(start:Date, end:Date):Number {
        return (end.getTime() - start.getTime());
    }
}
}
