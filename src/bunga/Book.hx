package bunga;

@:keep
@:expose
@:structInit
class Book {
    public static final standard:Array<Book> = [
        {id: "fmc", label: "Flore de Madagascar et Comores"},
        {id: "mbf", label: "Manuel de Botanique Forestière"},
    ];

    public var id:String;
    public var label:String;
}