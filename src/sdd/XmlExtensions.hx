package sdd;

class XmlExtensions {
    public static function firstElementNamed(xml: Null<Xml>, tagName: String): Null<Xml> {
        if (xml != null) {
            return xml.elementsNamed(tagName).next();
        } else {
            return null;
        }
    }

    public static function innerText(xml: Null<Xml>): String {
        if (xml == null) return "";

        final textNode = xml.firstChild();

        if (textNode != null) {
            return textNode.nodeValue;
        } else {
            return "";
        }
    }
}