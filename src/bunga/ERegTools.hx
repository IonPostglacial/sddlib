package bunga;

class ERegTools {
    public static function escape(string:String):String {
        return ~/[.*+?^${}()|[\]\\]/g.replace(string, '\\$&');
    }
}