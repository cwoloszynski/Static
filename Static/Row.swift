import UIKit

/// Row or Accessory selection callback.
public typealias SelectionAction = () -> Void

/// Representation of a table row.
public struct Row: Hashable, Equatable {

    // MARK: - Types

    /// Representation of a row accessory.
    public enum Accessory: Equatable {
        /// No accessory
        case none

        /// Chevron
        case disclosureIndicator

        /// Info button with chevron. Handles selection.
        case detailDisclosureButton(SelectionAction)

        /// Checkmark
        case checkmark

        /// Info button. Handles selection.
        case detailButton(SelectionAction)

        /// Custom view
        case view(UIView)

        /// Table view cell accessory type
        public var type: UITableViewCellAccessoryType {
            switch self {
            case .disclosureIndicator: return .disclosureIndicator
            case .detailDisclosureButton(_): return .detailDisclosureButton
            case .checkmark: return .checkmark
            case .detailButton(_): return .detailButton
            default: return .none
            }
        }

        /// Accessory view
        public var view: UIView? {
            switch self {
            case .view(let view): return view
            default: return nil
            }
        }

        /// Selection block for accessory buttons
        public var selectionAction: SelectionAction? {
            switch self {
            case .detailDisclosureButton(let selectionAction): return selectionAction
            case .detailButton(let selectionAction): return selectionAction
            default: return nil
            }
        }
        
        
    }

    public typealias Context = [String: Any]

    /// Representation of an editing action, when swiping to edit a cell.
    public struct EditAction {
        /// Title of the action's button.
        public let title: String
        
        /// Styling for button's action, used primarily for destructive actions.
        public let style: UITableViewRowActionStyle
        
        /// Background color of the button.
        public let backgroundColor: UIColor?
        
        /// Visual effect to be applied to the button's background.
        public let backgroundEffect: UIVisualEffect?
        
        /// Invoked when selecting the action.
        public let selectionAction: SelectionAction?
        
        public init(title: String, style: UITableViewRowActionStyle = .default, backgroundColor: UIColor? = nil, backgroundEffect: UIVisualEffect? = nil, selectionAction: SelectionAction? = nil) {
            self.title = title
            self.style = style
            self.backgroundColor = backgroundColor
            self.backgroundEffect = backgroundEffect
            self.selectionAction = selectionAction
        }
    }

    // MARK: - Properties

    /// Unique identifier for the row.
    public let uuid: String

    /// The row's primary text.
    public var text: String?

    /// The row's secondary text.
    public var detailText: String?

    /// Accessory for the row.
    public var accessory: Accessory

    /// Image for the row
    public var image: UIImage?

    /// Action to run when the row is selected.
    public var selectionAction: SelectionAction?

    public var swipeActionsConfiguration: UISwipeActionsConfiguration?
    
    /// View to be used for the row.
    public var cellClass: Cell.Type

    /// Additional information for the row.
    public var context: Context?
    
    /// Actions to show when swiping the cell, such as Delete.
    public var editActions: [EditAction]

    var canEdit: Bool {
        return editActions.count > 0
    }

    var isSelectable: Bool {
        return selectionAction != nil
    }

    var cellIdentifier: String {
        return cellClass.description()
    }

    public var hashValue: Int {
        return uuid.hashValue
    }


    // MARK: - Initializers

    public init(text: String? = nil, detailText: String? = nil, selectionAction: SelectionAction? = nil,
        image: UIImage? = nil, accessory: Accessory = .none, cellClass: Cell.Type? = nil, context: Context? = nil, editActions: [EditAction] = [], uuid: String = UUID().uuidString, swipeActionsConfiguration: UISwipeActionsConfiguration? = nil) {
        
        self.uuid = uuid
        self.text = text
        self.detailText = detailText
        self.selectionAction = selectionAction
        self.image = image
        self.accessory = accessory
        self.cellClass = cellClass ?? Value1Cell.self
        self.context = context
        self.editActions = editActions
        self.swipeActionsConfiguration = swipeActionsConfiguration
    }
}


public func ==(lhs: Row, rhs: Row) -> Bool {
    return lhs.uuid == rhs.uuid
}


public func ==(lhs: Row.Accessory, rhs: Row.Accessory) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none): return true
    case (.disclosureIndicator, .disclosureIndicator): return true
    case (.detailDisclosureButton(_), .detailDisclosureButton(_)): return true
    case (.checkmark, .checkmark): return true
    case (.detailButton(_), .detailButton(_)): return true
    case (.view(let l), .view(let r)): return l == r
    default: return false
    }
}
