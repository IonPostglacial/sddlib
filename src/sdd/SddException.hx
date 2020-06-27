package sdd;

import haxe.Exception;

class SddException extends Exception {
    public function new(message: String) {
        super("Invalid SDD: " + message);
    }
}