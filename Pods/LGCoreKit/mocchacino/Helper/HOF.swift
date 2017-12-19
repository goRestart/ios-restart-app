import Result

func delay<T, E>(result: Result<T, E>, completion: ((Result<T, E>) -> Void)?) {
    let deadline: DispatchTime = .now() + .milliseconds(50)
    DispatchQueue.main.asyncAfter(deadline: deadline) { 
        completion?(result)
    }
}
