import Foundation

/// The Item rendering policy describes which column a cell is going to be painted.
///
/// - shortestFirst: search for the shortest column and paint a cell in that column
/// - leftToRight: paint cells from left to right
/// - rightToLeft: paint cells from right to left
enum WaterfallLayoutItemRenderPolicy: Int {
    case shortestFirst
    case leftToRight
    case rightToLeft
}
