
private struct Header {
    weak var topConstraint: NSLayoutConstraint?
    var view: UIView
    
    init(view: UIView) {
        self.view = view
        topConstraint = nil
    }
}

final class StackHeaders: UIView {
    
    // MARK: - Private vars
    
    private var bottomConstraint: NSLayoutConstraint?
    private var headers: [Header] = []
    
    var isEmpty: Bool { return headers.isEmpty }
    
    // MARK: - Constructors
    
    convenience init() { self.init(frame: .zero) }
}

// MARK: - Submit methods

extension StackHeaders {
    func submit(header: UIView) {
        submitHeaderAndAddConstraints(header: Header(view: header))
    }
    
    func remove(header: UIView) {
        guard !headers.isEmpty else { return }
        guard headers.count != 1 else {
            invalidateAndRemoveConstraint(ofHeader: &headers[0])
            headers.removeLast()
            return
        }
        removeAndLinkConstraints(headerView: header)
    }
    
    func removeAll() {
        for header in headers {
            header.topConstraint?.isActive = false
            header.view.removeFromSuperview()
        }
        headers.removeAll()
    }
}

// MARK: - Helper methods

extension StackHeaders {
    
    private func submitHeaderAndAddConstraints(header: Header) {
        var mutableHeader = header
        defer { headers.append(mutableHeader) }
        addSubviewForAutoLayout(mutableHeader.view)
        guard headers.count > 0 else {
            inflateAtFirst(header: &mutableHeader)
            return
        }
        inflateAtLast(header: &mutableHeader)
    }
    
    private func inflateAtFirst(header: inout Header) {
        header.topConstraint = header.view.topAnchor.constraint(
            equalTo: topAnchor)
        var constraints = generateLeftAndRightConstraints(viewHeader: header.view)
        if let safeTopConstraint = header.topConstraint {
            constraints.append(safeTopConstraint)
        }
        bottomConstraint = generateBottomConstraint(with: header.view)
        if let safeBottomConstaint = bottomConstraint {
            constraints.append(safeBottomConstaint)
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    private func inflateAtLast(header: inout Header) {
        guard let lastHeaderView = headers.last?.view else { return }
        header.topConstraint = header.view.topAnchor.constraint(
            equalTo: lastHeaderView.bottomAnchor)
        var constraints = generateLeftAndRightConstraints(viewHeader: header.view)
        if let safeTopConstraint = header.topConstraint {
            constraints.append(safeTopConstraint)
        }
        bottomConstraint?.isActive = false
        bottomConstraint = generateBottomConstraint(with: header.view)
        if let safeBottomConstraint = bottomConstraint {
           constraints.append(safeBottomConstraint)
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    private func removeAndLinkConstraints(headerView: UIView) {
        let length = headers.count
        var i = 0
        while i < length {
            guard headers[i].view == headerView else {
                i += 1
                continue
            }
            bindHeaders(betweenPivot: i)
            invalidateAndRemoveConstraint(ofHeader: &headers[i])
            headers[i].view.removeFromSuperview()
            headers.remove(at: i)
            break
        }
    }
    
    private func bindHeaders(betweenPivot pivot: Int) {
        let isThereElemAfterPivot = pivot + 1 >= headers.count
        let isThereElemBeforePivot = pivot > 0
        
        if isThereElemAfterPivot {
            if isThereElemBeforePivot {
                NSLayoutConstraint.activate([
                    generateBottomConstraint(with: headers[pivot - 1].view)
                ])
            }
        } else {
            if isThereElemBeforePivot {
                NSLayoutConstraint.activate([
                    headers[pivot + 1].view.topAnchor.constraint(
                        equalTo: headers[pivot - 1].view.bottomAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    generateTopConstraint(with: headers[pivot + 1].view)
                ])
            }
        }
    }
    
    private func invalidateAndRemoveConstraint(ofHeader header: inout Header) {
        header.topConstraint?.isActive = false
        header.topConstraint = nil
    }
    
    private func generateLeftAndRightConstraints(viewHeader: UIView) -> [NSLayoutConstraint] {
        return [
            viewHeader.leftAnchor.constraint(equalTo: leftAnchor),
            viewHeader.rightAnchor.constraint(equalTo: rightAnchor)
        ]
    }
    
    private func generateTopConstraint(with viewHeader: UIView) -> NSLayoutConstraint {
        return viewHeader.topAnchor.constraint(equalTo: topAnchor)
    }
    
    private func generateBottomConstraint(with viewHeader: UIView) -> NSLayoutConstraint {
        return viewHeader.bottomAnchor.constraint(equalTo: bottomAnchor)
    }
}
