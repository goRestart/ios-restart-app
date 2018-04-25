public struct MockPreSignedUploadUrl: PreSignedUploadUrl {
    public var form: PreSignedUploadUrlForm
    public var expires: Date?
}

public struct MockPreSignedUploadUrlForm: PreSignedUploadUrlForm {
    public var inputs: [String: String]
    public var action: URL
}
