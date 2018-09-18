struct UriScheme {
   private enum UTM {
      static let medium = "utm_medium"
      static let source = "utm_source"
      static let campaign = "utm_campaign"
   }
   private enum Params {
      static let cardAction = "card-action"
      static let ratingSource = "rating-source"
   }
   private enum Sell {
      static let source = "source"
      static let category = "category"
      static let title = "title"
   }

   var deepLink: DeepLink

   static func buildFromLaunchOptions(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]) -> UriScheme? {
      guard let url = launchOptions[UIApplicationLaunchOptionsKey.url] as? URL else { return nil }
      return UriScheme.buildFromUrl(url)
   }

   static func buildFromUrl(_ url: URL) -> UriScheme? {
      guard let host = url.host, let schemeHost = UriSchemeHost(rawValue: host) else { return nil }

      let components = url.components
      let queryParams = url.queryParameters

      return buildFromHost(schemeHost, components: components, params: queryParams)
   }

   static func buildFromHost(_ host: UriSchemeHost, components: [String], params: [String : String]) -> UriScheme? {
      let campaign = params[UTM.campaign]
      let medium = params[UTM.medium]
      let source = DeepLinkSource(string: params[UTM.source])
      let cardActionParameter = params[Params.cardAction]

      switch host {
      case .appRating:
         let ratingSource = params[Params.ratingSource] ?? ""
         return UriScheme(deepLink: DeepLink.link(.appRating(source: ratingSource),
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .home:
         return UriScheme(deepLink: DeepLink.link(.home,
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .sell:
         let postingSource = params[Sell.source] ?? ""
         let category = params[Sell.category] ?? ""
         let title = params[Sell.title] ?? ""
         return UriScheme(deepLink: DeepLink.link(.sell(source: postingSource, category: category, title: title),
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .listing, .listings:
         guard let listingId = components.first else { return nil }
         return UriScheme(deepLink: DeepLink.link(.listing(listingId: listingId),
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .listingShare:
         guard let listingId = components.first else { return nil }
         return UriScheme(deepLink: DeepLink.link(.listingShare(listingId: listingId),
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .listingBumpUp:
         guard let listingId = components.first else { return nil }
         return UriScheme(deepLink: DeepLink.link(.listingBumpUp(listingId: listingId),
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .listingMarkAsSold:
         guard let listingId = components.first else { return nil }
         return UriScheme(deepLink: DeepLink.link(.listingMarkAsSold(listingId: listingId),
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .listingEdit:
         guard let listingId = components.first else { return nil }
         return UriScheme(deepLink: DeepLink.link(.listingEdit(listingId: listingId),
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .user:
         guard let userId = components.first else { return nil }
         return UriScheme(deepLink: DeepLink.link(.user(userId: userId),
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .chat:
         if let conversationId = params["c"], let message = params["m"] {
            // letgo://chat/?c=12345&m=abcde where c=conversation_id, m=message
            return UriScheme(deepLink: DeepLink.link(.conversationWithMessage(conversationId: conversationId,
                                                                              message: message),
                                                     campaign: campaign,
                                                     medium: medium,
                                                     source: source,
                                                     cardActionParameter: cardActionParameter))
         } else if let conversationId = params["c"] {
            // letgo://chat/?c=12345 where c=conversation_id
            return UriScheme(deepLink: DeepLink.link(.conversation(conversationId: conversationId),
                                                     campaign: campaign,
                                                     medium: medium,
                                                     source: source,
                                                     cardActionParameter: cardActionParameter))
         } else {
            return nil
         }
      case .chats:
         return UriScheme(deepLink: DeepLink.link(.conversations,
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .search:
         // Checking we have at least one parameter to search or filter by
         guard params.count > 0 else { return nil }
         return UriScheme(deepLink: DeepLink.link(.search(query: params[DeepLinkAction.SearchDeepLinkQueryParameters.query.rawValue],
                                                          categories: params[DeepLinkAction.SearchDeepLinkQueryParameters.categories.rawValue],
                                                          distanceRadius: params[DeepLinkAction.SearchDeepLinkQueryParameters.distanceRadius.rawValue],
                                                          sortCriteria: params[DeepLinkAction.SearchDeepLinkQueryParameters.sortCriteria.rawValue],
                                                          priceFlag: params[DeepLinkAction.SearchDeepLinkQueryParameters.priceFlag.rawValue],
                                                          minPrice: params[DeepLinkAction.SearchDeepLinkQueryParameters.minPrice.rawValue],
                                                          maxPrice: params[DeepLinkAction.SearchDeepLinkQueryParameters.maxPrice.rawValue]),
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .resetPassword:
         guard let token = params["token"] else { return nil }
         return UriScheme(deepLink: DeepLink.link(.resetPassword(token: token),
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .userRatings:
         return UriScheme(deepLink: DeepLink.link(.userRatings,
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .userRating:
         guard let ratingId = components.first else { return nil }
         return UriScheme(deepLink: DeepLink.link(.userRating(ratingId: ratingId),
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .notificationCenter:
         return UriScheme(deepLink: DeepLink.link(.notificationCenter,
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .updateApp:
         return UriScheme(deepLink: DeepLink.link(.appStore,
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .webView:
         guard let urlString = params["link"],
            let url = URL(string: urlString) else { return nil}
         return UriScheme(deepLink: DeepLink.link(.webView(url: url),
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .invite:
         guard let safeUsername = params["user-name"] else { return nil }
         guard let safeUserid = params["user-id"] else { return nil }
         return UriScheme(deepLink: DeepLink.link(.invite(userid: safeUserid, username: safeUsername),
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      case .userVerification:
         return UriScheme(deepLink: DeepLink.link(.userVerification,
                                                  campaign: campaign,
                                                  medium: medium,
                                                  source: source,
                                                  cardActionParameter: cardActionParameter))
      }
   }
}

enum UriSchemeHost: String {
   case appRating = "app_rating"
   case home = "home"
   case sell = "sell"
   case listing = "product"
   case listings = "products"
   case listingShare = "products_share"
   case listingBumpUp = "products_bump_up"
   case listingMarkAsSold = "products_mark_as_sold"
   case listingEdit = "products_edit"
   case user = "users"
   case chat = "chat"
   case chats = "chats"
   case search = "search"
   case resetPassword = "reset_password"
   case userRatings = "userreviews"
   case userRating = "userreview"
   case notificationCenter = "notification_center"
   case updateApp = "update_app"
   case webView = "webview"
   case invite = "app_invite"
   case userVerification = "user_verification"
}
