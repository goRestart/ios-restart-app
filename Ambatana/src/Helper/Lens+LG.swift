/// https://medium.com/@EnnioMa/functional-lenses-an-exploration-in-swift-25b4d3a6a536

public struct Lens<Container, T> {
    public let get: (Container) -> T
    public let set: (T, Container) -> Container
}

precedencegroup ComposePrecedence {
    associativity: left
}

infix operator >>> : ComposePrecedence

func >>> <Container, W, V>(lhs: Lens<Container, W>, rhs: Lens<W, V>) -> Lens<Container, V> {
    return Lens(get: { rhs.get(lhs.get($0)) },
                set: { (c, a) in return lhs.set(rhs.set(c, lhs.get(a)), a) }
    )
}
