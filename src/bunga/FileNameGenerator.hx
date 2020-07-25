package bunga;

using StringTools;

class FileNameGenerator {
    static var forbiddenChars = [" ", "*", ".", '"', "/", "\\", "[", "]", ":", ";", "|", ","];

    public static function generate(name:String):String {
        var generatedName = name;
        for (char in forbiddenChars) {
            generatedName = generatedName.replace(char, "_");
        }
        return generatedName;
    }
}