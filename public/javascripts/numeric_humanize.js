Number.prototype.humanize = function(rounding, delimiter, separator) {
    rounding = (typeof rounding != 'undefined') ?  rounding : 2;
    delimiter = (typeof delimiter != 'undefined') ? delimiter : ',';
    separator = (typeof separator != 'undefined') ? separator : '.';

    var value = (function(value) {
        if (rounding == 0) return Math.round(value);
        var round_by = Math.pow(10, rounding);
        return (Math.round(value * (round_by)) / round_by);
    })(this);

    parts = value.toString().split('.');
    parts[0] = parts[0].gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "#{1}" + delimiter);
    return parts.join(separator);
};