@main
public struct Mnemonize {
    public private(set) var text = "Hello, World!"

    public static func main() {
        print(Mnemonize().text)
    }
}
