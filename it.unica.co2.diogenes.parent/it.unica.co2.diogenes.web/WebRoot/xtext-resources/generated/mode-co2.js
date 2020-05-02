define(["ace/lib/oop", "ace/mode/text", "ace/mode/text_highlight_rules"], function(oop, mText, mTextHighlightRules) {
    var HighlightRules = function() {
        var keywords = "True|after|ask|bool|boolean|case|contract|default|do|else|false|from|honesty|if|import|int|nil|package|process|receive|retract|send|session|single|specification|string|switch|t|tell|tellAndReturn|telll|then|to|true|unit";
        this.$rules = {
            "start": [
                {token: "comment", regex: "\\/\\/.*$"},
                {token: "comment", regex: "\\/\\*", next : "comment"},
                {token: "string", regex: '["](?:(?:\\\\.)|(?:[^"\\\\]))*?["]'},
                {token: "string", regex: "['](?:(?:\\\\.)|(?:[^'\\\\]))*?[']"},
                {token: "constant.numeric", regex: "[+-]?\\d+(?:(?:\\.\\d*)?(?:[eE][+-]?\\d+)?)?\\b"},
                {token: "lparen", regex: "[\\[({]"},
                {token: "rparen", regex: "[\\])}]"},
                {token: "keyword", regex: "\\b(?:" + keywords + ")\\b"}
            ],
            "comment": [
                {token: "comment", regex: ".*?\\*\\/", next : "start"},
                {token: "comment", regex: ".+"}
            ]
        };
    };
    oop.inherits(HighlightRules, mTextHighlightRules.TextHighlightRules);

    var Mode = function() {
        this.HighlightRules = HighlightRules;
    };
    oop.inherits(Mode, mText.Mode);
    Mode.prototype.$id = "xtext/co2";
    Mode.prototype.getCompletions = function(state, session, pos, prefix) {
        return [];
    }

    return {
        Mode: Mode
    };
});
