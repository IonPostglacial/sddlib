package sdd;

class SddRefException extends SddException {
    public function new(sourceElement: String, targetElement: String, ref: String) {
        super("A '" + sourceElement + "' references a missing '" + targetElement + "': " + ref);
    }
}