import BricBrac

public enum ResolveMode : String, Equatable, Codable {
    case independent
    case shared
}

public typealias Parse = Dictionary<String, ParseValue>
public typealias ParseValue = ParseValueTypes.Choice
public enum ParseValueTypes {

    public typealias Choice = OneOf6<ExplicitNull, String, Type3, Type4, Type5, Type6>

    public enum Type3 : String, Equatable, Codable {
        case string
    }

    public enum Type4 : String, Equatable, Codable {
        case boolean
    }

    public enum Type5 : String, Equatable, Codable {
        case date
    }

    public enum Type6 : String, Equatable, Codable {
        case number
    }
}

public struct TitleParams : Equatable, Codable {
    /// The title text.
    public var text: String
    /// The anchor position for placing the title. One of `"start"`, `"middle"`, or `"end"`. For example, with an orientation of top these anchor positions map to a left-, center-, or right-aligned title.
    /// __Default value:__ `"middle"` for [single](https://vega.github.io/vega-lite/docs/spec.html) and [layered](https://vega.github.io/vega-lite/docs/layer.html) views.
    /// `"start"` for other composite views.
    /// __Note:__ [For now](https://github.com/vega/vega-lite/issues/2875), `anchor` is only customizable only for [single](https://vega.github.io/vega-lite/docs/spec.html) and [layered](https://vega.github.io/vega-lite/docs/layer.html) views.  For other composite views, `anchor` is always `"start"`.
    public var anchor: Anchor?
    /// The orthogonal offset in pixels by which to displace the title from its position along the edge of the chart.
    public var offset: Double?
    /// The orientation of the title relative to the chart. One of `"top"` (the default), `"bottom"`, `"left"`, or `"right"`.
    public var orient: TitleOrient?
    /// A [mark style property](https://vega.github.io/vega-lite/docs/config.html#style) to apply to the title text mark.
    /// __Default value:__ `"group-title"`.
    public var style: StyleChoice?

    public init(text: String, anchor: Anchor? = .none, offset: Double? = .none, orient: TitleOrient? = .none, style: StyleChoice? = .none) {
        self.text = text 
        self.anchor = anchor 
        self.offset = offset 
        self.orient = orient 
        self.style = style 
    }

    public enum CodingKeys : String, CodingKey {
        case text
        case anchor
        case offset
        case orient
        case style
    }

    /// A [mark style property](https://vega.github.io/vega-lite/docs/config.html#style) to apply to the title text mark.
    /// __Default value:__ `"group-title"`.
    public typealias StyleChoice = OneOf2<String, [String]>
}

/// Properties of a legend or boolean flag for determining whether to show it.
public struct Legend : Equatable, Codable {
    /// Padding (in pixels) between legend entries in a symbol legend.
    public var entryPadding: Double?
    /// The formatting pattern for labels. This is D3's [number format pattern](https://github.com/d3/d3-format#locale_format) for quantitative fields and D3's [time format pattern](https://github.com/d3/d3-time-format#locale_format) for time field.
    /// See the [format documentation](https://vega.github.io/vega-lite/docs/format.html) for more information.
    /// __Default value:__  derived from [numberFormat](https://vega.github.io/vega-lite/docs/config.html#format) config for quantitative fields and from [timeFormat](https://vega.github.io/vega-lite/docs/config.html#format) config for temporal fields.
    public var format: String?
    /// The offset, in pixels, by which to displace the legend from the edge of the enclosing group or data rectangle.
    /// __Default value:__  `0`
    public var offset: Double?
    /// The orientation of the legend, which determines how the legend is positioned within the scene. One of "left", "right", "top-left", "top-right", "bottom-left", "bottom-right", "none".
    /// __Default value:__ `"right"`
    public var orient: LegendOrient?
    /// The padding, in pixels, between the legend and axis.
    public var padding: Double?
    /// The desired number of tick values for quantitative legends.
    public var tickCount: Double?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?
    /// The type of the legend. Use `"symbol"` to create a discrete legend and `"gradient"` for a continuous color gradient.
    /// __Default value:__ `"gradient"` for non-binned quantitative fields and temporal fields; `"symbol"` otherwise.
    public var type: `Type`?
    /// Explicitly set the visible legend values.
    public var values: ValuesChoice?
    /// A non-positive integer indicating z-index of the legend.
    /// If zindex is 0, legend should be drawn behind all chart elements.
    /// To put them in front, use zindex = 1.
    public var zindex: Double?

    public init(entryPadding: Double? = .none, format: String? = .none, offset: Double? = .none, orient: LegendOrient? = .none, padding: Double? = .none, tickCount: Double? = .none, title: Title? = .none, type: `Type`? = .none, values: ValuesChoice? = .none, zindex: Double? = .none) {
        self.entryPadding = entryPadding 
        self.format = format 
        self.offset = offset 
        self.orient = orient 
        self.padding = padding 
        self.tickCount = tickCount 
        self.title = title 
        self.type = type 
        self.values = values 
        self.zindex = zindex 
    }

    public enum CodingKeys : String, CodingKey {
        case entryPadding
        case format
        case offset
        case orient
        case padding
        case tickCount
        case title
        case type
        case values
        case zindex
    }

    /// Properties of a legend or boolean flag for determining whether to show it.
    public typealias Title = OneOf2<String, ExplicitNull>

    /// The type of the legend. Use `"symbol"` to create a discrete legend and `"gradient"` for a continuous color gradient.
    /// __Default value:__ `"gradient"` for non-binned quantitative fields and temporal fields; `"symbol"` otherwise.
    public enum `Type` : String, Equatable, Codable {
        case symbol
        case gradient
    }

    /// Explicitly set the visible legend values.
    public typealias ValuesChoice = OneOf3<[Double], [String], [DateTime]>
}

public enum FontStyle : String, Equatable, Codable {
    case normal
    case italic
}

public enum WindowOnlyOp : String, Equatable, Codable {
    case row_number
    case rank
    case dense_rank
    case percent_rank
    case cume_dist
    case ntile
    case lag
    case lead
    case first_value
    case last_value
    case nth_value
}

public struct LineConfig : Equatable, Codable {
    /// The horizontal alignment of the text. One of `"left"`, `"right"`, `"center"`.
    public var align: HorizontalAlign?
    /// The rotation angle of the text, in degrees.
    public var angle: Double?
    /// The vertical alignment of the text. One of `"top"`, `"middle"`, `"bottom"`.
    /// __Default value:__ `"middle"`
    public var baseline: VerticalAlign?
    /// Default color.  Note that `fill` and `stroke` have higher precedence than `color` and will override `color`.
    /// __Default value:__ <span style="color: #4682b4;">&#9632;</span> `"#4682b4"`
    /// __Note:__ This property cannot be used in a [style config](https://vega.github.io/vega-lite/docs/mark.html#style-config).
    public var color: String?
    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public var cursor: Cursor?
    /// The horizontal offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dx: Double?
    /// The vertical offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dy: Double?
    /// Default Fill Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var fill: String?
    /// The fill opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var fillOpacity: Double?
    /// Whether the mark's color should be used as fill color instead of stroke color.
    /// __Default value:__ `true` for all marks except `point` and `false` for `point`.
    /// __Applicable for:__ `bar`, `point`, `circle`, `square`, and `area` marks.
    /// __Note:__ This property cannot be used in a [style config](https://vega.github.io/vega-lite/docs/mark.html#style-config).
    public var filled: Bool?
    /// The typeface to set the text in (e.g., `"Helvetica Neue"`).
    public var font: String?
    /// The font size, in pixels.
    public var fontSize: Double?
    /// The font style (e.g., `"italic"`).
    public var fontStyle: FontStyle?
    /// The font weight.
    /// This can be either a string (e.g `"bold"`, `"normal"`) or a number (`100`, `200`, `300`, ..., `900` where `"normal"` = `400` and `"bold"` = `700`).
    public var fontWeight: FontWeight?
    /// A URL to load upon mouse click. If defined, the mark acts as a hyperlink.
    public var href: String?
    /// The line interpolation method to use for line and area marks. One of the following:
    /// - `"linear"`: piecewise linear segments, as in a polyline.
    /// - `"linear-closed"`: close the linear segments to form a polygon.
    /// - `"step"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"step-before"`: alternate between vertical and horizontal segments, as in a step function.
    /// - `"step-after"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"basis"`: a B-spline, with control point duplication on the ends.
    /// - `"basis-open"`: an open B-spline; may not intersect the start or end.
    /// - `"basis-closed"`: a closed B-spline, as in a loop.
    /// - `"cardinal"`: a Cardinal spline, with control point duplication on the ends.
    /// - `"cardinal-open"`: an open Cardinal spline; may not intersect the start or end, but will intersect other control points.
    /// - `"cardinal-closed"`: a closed Cardinal spline, as in a loop.
    /// - `"bundle"`: equivalent to basis, except the tension parameter is used to straighten the spline.
    /// - `"monotone"`: cubic interpolation that preserves monotonicity in y.
    public var interpolate: Interpolate?
    /// The maximum length of the text mark in pixels (default 0, indicating no limit). The text value will be automatically truncated if the rendered size exceeds the limit.
    public var limit: Double?
    /// The overall opacity (value between [0,1]).
    /// __Default value:__ `0.7` for non-aggregate plots with `point`, `tick`, `circle`, or `square` marks or layered `bar` charts and `1` otherwise.
    public var opacity: Double?
    /// The orientation of a non-stacked bar, tick, area, and line charts.
    /// The value is either horizontal (default) or vertical.
    /// - For bar, rule and tick, this determines whether the size of the bar and tick
    /// should be applied to x or y dimension.
    /// - For area, this property determines the orient property of the Vega output.
    /// - For line and trail marks, this property determines the sort order of the points in the line
    /// if `config.sortLineBy` is not specified.
    /// For stacked charts, this is always determined by the orientation of the stack;
    /// therefore explicitly specified value will be ignored.
    public var orient: Orient?
    /// A flag for overlaying points on top of line or area marks, or an object defining the properties of the overlayed points.
    /// - If this property is `"transparent"`, transparent points will be used (for enhancing tooltips and selections).
    /// - If this property is an empty object (`{}`) or `true`, filled points with default properties will be used.
    /// - If this property is `false`, no points would be automatically added to line or area marks.
    /// __Default value:__ `false`.
    public var point: PointChoice?
    /// Polar coordinate radial offset, in pixels, of the text label from the origin determined by the `x` and `y` properties.
    public var radius: Double?
    /// The default symbol shape to use. One of: `"circle"` (default), `"square"`, `"cross"`, `"diamond"`, `"triangle-up"`, or `"triangle-down"`, or a custom SVG path.
    /// __Default value:__ `"circle"`
    public var shape: String?
    /// The pixel area each the point/circle/square.
    /// For example: in the case of circles, the radius is determined in part by the square root of the size value.
    /// __Default value:__ `30`
    public var size: Double?
    /// Default Stroke Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var stroke: String?
    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public var strokeCap: StrokeCap?
    /// An array of alternating stroke, space lengths for creating dashed or dotted lines.
    public var strokeDash: [StrokeDashItem]?
    /// The offset (in pixels) into which to begin drawing with the stroke dash array.
    public var strokeDashOffset: Double?
    /// The stroke opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var strokeOpacity: Double?
    /// The stroke width, in pixels.
    public var strokeWidth: Double?
    /// Depending on the interpolation type, sets the tension parameter (for line and area marks).
    public var tension: Double?
    /// Placeholder text if the `text` channel is not specified
    public var text: String?
    /// Polar coordinate angle, in radians, of the text label from the origin determined by the `x` and `y` properties. Values for `theta` follow the same convention of `arc` mark `startAngle` and `endAngle` properties: angles are measured in radians, with `0` indicating "north".
    public var theta: Double?

    public init(align: HorizontalAlign? = .none, angle: Double? = .none, baseline: VerticalAlign? = .none, color: String? = .none, cursor: Cursor? = .none, dx: Double? = .none, dy: Double? = .none, fill: String? = .none, fillOpacity: Double? = .none, filled: Bool? = .none, font: String? = .none, fontSize: Double? = .none, fontStyle: FontStyle? = .none, fontWeight: FontWeight? = .none, href: String? = .none, interpolate: Interpolate? = .none, limit: Double? = .none, opacity: Double? = .none, orient: Orient? = .none, point: PointChoice? = .none, radius: Double? = .none, shape: String? = .none, size: Double? = .none, stroke: String? = .none, strokeCap: StrokeCap? = .none, strokeDash: [StrokeDashItem]? = .none, strokeDashOffset: Double? = .none, strokeOpacity: Double? = .none, strokeWidth: Double? = .none, tension: Double? = .none, text: String? = .none, theta: Double? = .none) {
        self.align = align 
        self.angle = angle 
        self.baseline = baseline 
        self.color = color 
        self.cursor = cursor 
        self.dx = dx 
        self.dy = dy 
        self.fill = fill 
        self.fillOpacity = fillOpacity 
        self.filled = filled 
        self.font = font 
        self.fontSize = fontSize 
        self.fontStyle = fontStyle 
        self.fontWeight = fontWeight 
        self.href = href 
        self.interpolate = interpolate 
        self.limit = limit 
        self.opacity = opacity 
        self.orient = orient 
        self.point = point 
        self.radius = radius 
        self.shape = shape 
        self.size = size 
        self.stroke = stroke 
        self.strokeCap = strokeCap 
        self.strokeDash = strokeDash 
        self.strokeDashOffset = strokeDashOffset 
        self.strokeOpacity = strokeOpacity 
        self.strokeWidth = strokeWidth 
        self.tension = tension 
        self.text = text 
        self.theta = theta 
    }

    public enum CodingKeys : String, CodingKey {
        case align
        case angle
        case baseline
        case color
        case cursor
        case dx
        case dy
        case fill
        case fillOpacity
        case filled
        case font
        case fontSize
        case fontStyle
        case fontWeight
        case href
        case interpolate
        case limit
        case opacity
        case orient
        case point
        case radius
        case shape
        case size
        case stroke
        case strokeCap
        case strokeDash
        case strokeDashOffset
        case strokeOpacity
        case strokeWidth
        case tension
        case text
        case theta
    }

    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public enum Cursor : String, Equatable, Codable {
        case auto
        case `default` = "default"
        case none
        case contextMenu = "context-menu"
        case help
        case pointer
        case progress
        case wait
        case cell
        case crosshair
        case text
        case verticalText = "vertical-text"
        case alias
        case copy
        case move
        case noDrop = "no-drop"
        case notAllowed = "not-allowed"
        case eResize = "e-resize"
        case nResize = "n-resize"
        case neResize = "ne-resize"
        case nwResize = "nw-resize"
        case sResize = "s-resize"
        case seResize = "se-resize"
        case swResize = "sw-resize"
        case wResize = "w-resize"
        case ewResize = "ew-resize"
        case nsResize = "ns-resize"
        case neswResize = "nesw-resize"
        case nwseResize = "nwse-resize"
        case colResize = "col-resize"
        case rowResize = "row-resize"
        case allScroll = "all-scroll"
        case zoomIn = "zoom-in"
        case zoomOut = "zoom-out"
        case grab
        case grabbing
    }

    /// A flag for overlaying points on top of line or area marks, or an object defining the properties of the overlayed points.
    /// - If this property is `"transparent"`, transparent points will be used (for enhancing tooltips and selections).
    /// - If this property is an empty object (`{}`) or `true`, filled points with default properties will be used.
    /// - If this property is `false`, no points would be automatically added to line or area marks.
    /// __Default value:__ `false`.
    public typealias PointChoice = PointTypes.Choice
    public enum PointTypes {

        public typealias Choice = OneOf3<Bool, MarkConfig, Type3>

        public enum Type3 : String, Equatable, Codable {
            case transparent
        }
    }

    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public enum StrokeCap : String, Equatable, Codable {
        case butt
        case round
        case square
    }

    public typealias StrokeDashItem = Double
}

public struct WindowTransform : Equatable, Codable {
    /// The definition of the fields in the window, and what calculations to use.
    public var window: [WindowFieldDef]
    /// A frame specification as a two-element array indicating how the sliding window should proceed. The array entries should either be a number indicating the offset from the current data object, or null to indicate unbounded rows preceding or following the current data object. The default value is `[null, 0]`, indicating that the sliding window includes the current object and all preceding objects. The value `[-5, 5]` indicates that the window should include five objects preceding and five objects following the current object. Finally, `[null, null]` indicates that the window frame should always include all data objects. The only operators affected are the aggregation operations and the `first_value`, `last_value`, and `nth_value` window operations. The other window operations are not affected by this.
    /// __Default value:__:  `[null, 0]` (includes the current object and all preceding objects)
    public var frame: [FrameItemChoice]?
    /// The data fields for partitioning the data objects into separate windows. If unspecified, all data points will be a single group.
    public var groupby: [GroupbyItem]?
    /// Indicates if the sliding window frame should ignore peer values. (Peer values are those considered identical by the sort criteria). The default is false, causing the window frame to expand to include all peer values. If set to true, the window frame will be defined by offset values only. This setting only affects those operations that depend on the window frame, namely aggregation operations and the first_value, last_value, and nth_value window operations.
    /// __Default value:__ `false`
    public var ignorePeers: Bool?
    /// A sort field definition for sorting data objects within a window. If two data objects are considered equal by the comparator, they are considered “peer” values of equal rank. If sort is not specified, the order is undefined: data objects are processed in the order they are observed and none are considered peers (the ignorePeers parameter is ignored and treated as if set to `true`).
    public var sort: [SortField]?

    public init(window: [WindowFieldDef] = [], frame: [FrameItemChoice]? = .none, groupby: [GroupbyItem]? = .none, ignorePeers: Bool? = .none, sort: [SortField]? = .none) {
        self.window = window 
        self.frame = frame 
        self.groupby = groupby 
        self.ignorePeers = ignorePeers 
        self.sort = sort 
    }

    public enum CodingKeys : String, CodingKey {
        case window
        case frame
        case groupby
        case ignorePeers
        case sort
    }

    public typealias FrameItemChoice = OneOf2<ExplicitNull, Double>

    public typealias GroupbyItem = String
}

public enum AxisOrient : String, Equatable, Codable {
    case top
    case right
    case left
    case bottom
}

public typealias Spec = OneOf6<CompositeUnitSpec, LayerSpec, FacetSpec, RepeatSpec, VConcatSpec, HConcatSpec>

public struct ConditionalPredicateTextFieldDef : Equatable, Codable {
    public var test: LogicalOperandPredicate
    /// The encoded field's type of measurement (`"quantitative"`, `"temporal"`, `"ordinal"`, or `"nominal"`).
    /// It can also be a `"geojson"` type for encoding ['geoshape'](https://vega.github.io/vega-lite/docs/geoshape.html).
    public var type: `Type`
    /// Aggregation function for the field
    /// (e.g., `mean`, `sum`, `median`, `min`, `max`, `count`).
    /// __Default value:__ `undefined` (None)
    public var aggregate: Aggregate?
    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public var bin: BinChoice?
    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public var field: FieldChoice?
    /// The [formatting pattern](https://vega.github.io/vega-lite/docs/format.html) for a text field. If not defined, this will be determined automatically.
    public var format: String?
    /// Time unit (e.g., `year`, `yearmonth`, `month`, `hours`) for a temporal field.
    /// or [a temporal field that gets casted as ordinal](https://vega.github.io/vega-lite/docs/type.html#cast).
    /// __Default value:__ `undefined` (None)
    public var timeUnit: TimeUnit?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?

    public init(test: LogicalOperandPredicate, type: `Type`, aggregate: Aggregate? = .none, bin: BinChoice? = .none, field: FieldChoice? = .none, format: String? = .none, timeUnit: TimeUnit? = .none, title: Title? = .none) {
        self.test = test 
        self.type = type 
        self.aggregate = aggregate 
        self.bin = bin 
        self.field = field 
        self.format = format 
        self.timeUnit = timeUnit 
        self.title = title 
    }

    public enum CodingKeys : String, CodingKey {
        case test
        case type
        case aggregate
        case bin
        case field
        case format
        case timeUnit
        case title
    }

    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public typealias BinChoice = OneOf2<Bool, BinParams>

    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public typealias FieldChoice = OneOf2<String, RepeatRef>

    public typealias Title = OneOf2<String, ExplicitNull>
}

/// Binning properties or boolean flag for determining whether to bin data or not.
public struct BinParams : Equatable, Codable {
    /// The number base to use for automatic bin determination (default is base 10).
    /// __Default value:__ `10`
    public var base: Double?
    /// Scale factors indicating allowable subdivisions. The default value is [5, 2], which indicates that for base 10 numbers (the default base), the method may consider dividing bin sizes by 5 and/or 2. For example, for an initial step size of 10, the method can check if bin sizes of 2 (= 10/5), 5 (= 10/2), or 1 (= 10/(5*2)) might also satisfy the given constraints.
    /// __Default value:__ `[5, 2]`
    public var divide: [DivideItem]?
    /// A two-element (`[min, max]`) array indicating the range of desired bin values.
    public var extent: [ExtentItem]?
    /// Maximum number of bins.
    /// __Default value:__ `6` for `row`, `column` and `shape` channels; `10` for other channels
    public var maxbins: Double?
    /// A minimum allowable step size (particularly useful for integer values).
    public var minstep: Double?
    /// If true (the default), attempts to make the bin boundaries use human-friendly boundaries, such as multiples of ten.
    public var nice: Bool?
    /// An exact step size to use between bins.
    /// __Note:__ If provided, options such as maxbins will be ignored.
    public var step: Double?
    /// An array of allowable step sizes to choose from.
    public var steps: [StepsItem]?

    public init(base: Double? = .none, divide: [DivideItem]? = .none, extent: [ExtentItem]? = .none, maxbins: Double? = .none, minstep: Double? = .none, nice: Bool? = .none, step: Double? = .none, steps: [StepsItem]? = .none) {
        self.base = base 
        self.divide = divide 
        self.extent = extent 
        self.maxbins = maxbins 
        self.minstep = minstep 
        self.nice = nice 
        self.step = step 
        self.steps = steps 
    }

    public enum CodingKeys : String, CodingKey {
        case base
        case divide
        case extent
        case maxbins
        case minstep
        case nice
        case step
        case steps
    }

    public typealias DivideItem = Double

    public typealias ExtentItem = Double

    public typealias StepsItem = Double
}

public enum TitleOrient : String, Equatable, Codable {
    case top
    case bottom
    case left
    case right
}

public enum VerticalAlign : String, Equatable, Codable {
    case top
    case middle
    case bottom
}

public struct SingleSelection : Equatable, Codable {
    public var type: `Type`
    /// Establish a two-way binding between a single selection and input elements
    /// (also known as dynamic query widgets). A binding takes the form of
    /// Vega's [input element binding definition](https://vega.github.io/vega/docs/signals/#bind)
    /// or can be a mapping between projected field/encodings and binding definitions.
    /// See the [bind transform](https://vega.github.io/vega-lite/docs/bind.html) documentation for more information.
    public var bind: BindChoice?
    /// By default, all data values are considered to lie within an empty selection.
    /// When set to `none`, empty selections contain no data values.
    public var empty: Empty?
    /// An array of encoding channels. The corresponding data field values
    /// must match for a data tuple to fall within the selection.
    public var encodings: [SingleDefChannel]?
    /// An array of field names whose values must match for a data tuple to
    /// fall within the selection.
    public var fields: [FieldsItem]?
    /// When true, an invisible voronoi diagram is computed to accelerate discrete
    /// selection. The data value _nearest_ the mouse cursor is added to the selection.
    /// See the [nearest transform](https://vega.github.io/vega-lite/docs/nearest.html) documentation for more information.
    public var nearest: Bool?
    /// A [Vega event stream](https://vega.github.io/vega/docs/event-streams/) (object or selector) that triggers the selection.
    /// For interval selections, the event stream must specify a [start and end](https://vega.github.io/vega/docs/event-streams/#between-filters).
    public var on: VgEventStream?
    /// With layered and multi-view displays, a strategy that determines how
    /// selections' data queries are resolved when applied in a filter transform,
    /// conditional encoding rule, or scale domain.
    public var resolve: SelectionResolution?

    public init(type: `Type` = .single, bind: BindChoice? = .none, empty: Empty? = .none, encodings: [SingleDefChannel]? = .none, fields: [FieldsItem]? = .none, nearest: Bool? = .none, on: VgEventStream? = .none, resolve: SelectionResolution? = .none) {
        self.type = type 
        self.bind = bind 
        self.empty = empty 
        self.encodings = encodings 
        self.fields = fields 
        self.nearest = nearest 
        self.on = on 
        self.resolve = resolve 
    }

    public enum CodingKeys : String, CodingKey {
        case type
        case bind
        case empty
        case encodings
        case fields
        case nearest
        case on
        case resolve
    }

    public enum `Type` : String, Equatable, Codable {
        case single
    }

    /// Establish a two-way binding between a single selection and input elements
    /// (also known as dynamic query widgets). A binding takes the form of
    /// Vega's [input element binding definition](https://vega.github.io/vega/docs/signals/#bind)
    /// or can be a mapping between projected field/encodings and binding definitions.
    /// See the [bind transform](https://vega.github.io/vega-lite/docs/bind.html) documentation for more information.
    public typealias BindChoice = BindTypes.Choice
    public enum BindTypes {

        public typealias Choice = OneOf2<VgBinding, Type2>

        public typealias Type2 = Dictionary<String, Type2Value>
        public typealias Type2Value = VgBinding
    }

    /// By default, all data values are considered to lie within an empty selection.
    /// When set to `none`, empty selections contain no data values.
    public enum Empty : String, Equatable, Codable {
        case all
        case none
    }

    public typealias FieldsItem = String
}

public enum BasicType : String, Equatable, Codable {
    case quantitative
    case ordinal
    case temporal
    case nominal
}

public struct FieldEqualPredicate : Equatable, Codable {
    /// The value that the field should be equal to.
    public var equal: EqualChoice
    /// Field to be filtered.
    public var field: String
    /// Time unit for the field to be filtered.
    public var timeUnit: TimeUnit?

    public init(equal: EqualChoice, field: String, timeUnit: TimeUnit? = .none) {
        self.equal = equal 
        self.field = field 
        self.timeUnit = timeUnit 
    }

    public enum CodingKeys : String, CodingKey {
        case equal
        case field
        case timeUnit
    }

    /// The value that the field should be equal to.
    public typealias EqualChoice = OneOf4<String, Double, Bool, DateTime>
}

/// Defines how scales, axes, and legends from different specs should be combined. Resolve is a mapping from `scale`, `axis`, and `legend` to a mapping from channels to resolutions.
public struct Resolve : Equatable, Codable {
    public var axis: AxisResolveMap?
    public var legend: LegendResolveMap?
    public var scale: ScaleResolveMap?

    public init(axis: AxisResolveMap? = .none, legend: LegendResolveMap? = .none, scale: ScaleResolveMap? = .none) {
        self.axis = axis 
        self.legend = legend 
        self.scale = scale 
    }

    public enum CodingKeys : String, CodingKey {
        case axis
        case legend
        case scale
    }
}

public typealias ConditionalValueDef = OneOf2<ConditionalPredicateValueDef, ConditionalSelectionValueDef>

public struct TextFieldDef : Equatable, Codable {
    /// The encoded field's type of measurement (`"quantitative"`, `"temporal"`, `"ordinal"`, or `"nominal"`).
    /// It can also be a `"geojson"` type for encoding ['geoshape'](https://vega.github.io/vega-lite/docs/geoshape.html).
    public var type: `Type`
    /// Aggregation function for the field
    /// (e.g., `mean`, `sum`, `median`, `min`, `max`, `count`).
    /// __Default value:__ `undefined` (None)
    public var aggregate: Aggregate?
    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public var bin: BinChoice?
    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public var field: FieldChoice?
    /// The [formatting pattern](https://vega.github.io/vega-lite/docs/format.html) for a text field. If not defined, this will be determined automatically.
    public var format: String?
    /// Time unit (e.g., `year`, `yearmonth`, `month`, `hours`) for a temporal field.
    /// or [a temporal field that gets casted as ordinal](https://vega.github.io/vega-lite/docs/type.html#cast).
    /// __Default value:__ `undefined` (None)
    public var timeUnit: TimeUnit?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?

    public init(type: `Type`, aggregate: Aggregate? = .none, bin: BinChoice? = .none, field: FieldChoice? = .none, format: String? = .none, timeUnit: TimeUnit? = .none, title: Title? = .none) {
        self.type = type 
        self.aggregate = aggregate 
        self.bin = bin 
        self.field = field 
        self.format = format 
        self.timeUnit = timeUnit 
        self.title = title 
    }

    public enum CodingKeys : String, CodingKey {
        case type
        case aggregate
        case bin
        case field
        case format
        case timeUnit
        case title
    }

    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public typealias BinChoice = OneOf2<Bool, BinParams>

    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public typealias FieldChoice = OneOf2<String, RepeatRef>

    public typealias Title = OneOf2<String, ExplicitNull>
}

public struct ConditionalPredicateMarkPropFieldDef : Equatable, Codable {
    public var test: LogicalOperandPredicate
    /// The encoded field's type of measurement (`"quantitative"`, `"temporal"`, `"ordinal"`, or `"nominal"`).
    /// It can also be a `"geojson"` type for encoding ['geoshape'](https://vega.github.io/vega-lite/docs/geoshape.html).
    public var type: `Type`
    /// Aggregation function for the field
    /// (e.g., `mean`, `sum`, `median`, `min`, `max`, `count`).
    /// __Default value:__ `undefined` (None)
    public var aggregate: Aggregate?
    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public var bin: BinChoice?
    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public var field: FieldChoice?
    /// An object defining properties of the legend.
    /// If `null`, the legend for the encoding channel will be removed.
    /// __Default value:__ If undefined, default [legend properties](https://vega.github.io/vega-lite/docs/legend.html) are applied.
    public var legend: LegendChoice?
    /// An object defining properties of the channel's scale, which is the function that transforms values in the data domain (numbers, dates, strings, etc) to visual values (pixels, colors, sizes) of the encoding channels.
    /// If `null`, the scale will be [disabled and the data value will be directly encoded](https://vega.github.io/vega-lite/docs/scale.html#disable).
    /// __Default value:__ If undefined, default [scale properties](https://vega.github.io/vega-lite/docs/scale.html) are applied.
    public var scale: ScaleChoice?
    /// Sort order for the encoded field.
    /// Supported `sort` values include `"ascending"`, `"descending"`, `null` (no sorting), or an array specifying the preferred order of values.
    /// For fields with discrete domains, `sort` can also be a [sort field definition object](https://vega.github.io/vega-lite/docs/sort.html#sort-field).
    /// For `sort` as an [array specifying the preferred order of values](https://vega.github.io/vega-lite/docs/sort.html#sort-array), the sort order will obey the values in the array, followed by any unspecified values in their original order.
    /// __Default value:__ `"ascending"`
    public var sort: SortChoice?
    /// Time unit (e.g., `year`, `yearmonth`, `month`, `hours`) for a temporal field.
    /// or [a temporal field that gets casted as ordinal](https://vega.github.io/vega-lite/docs/type.html#cast).
    /// __Default value:__ `undefined` (None)
    public var timeUnit: TimeUnit?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?

    public init(test: LogicalOperandPredicate, type: `Type`, aggregate: Aggregate? = .none, bin: BinChoice? = .none, field: FieldChoice? = .none, legend: LegendChoice? = .none, scale: ScaleChoice? = .none, sort: SortChoice? = .none, timeUnit: TimeUnit? = .none, title: Title? = .none) {
        self.test = test 
        self.type = type 
        self.aggregate = aggregate 
        self.bin = bin 
        self.field = field 
        self.legend = legend 
        self.scale = scale 
        self.sort = sort 
        self.timeUnit = timeUnit 
        self.title = title 
    }

    public enum CodingKeys : String, CodingKey {
        case test
        case type
        case aggregate
        case bin
        case field
        case legend
        case scale
        case sort
        case timeUnit
        case title
    }

    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public typealias BinChoice = OneOf2<Bool, BinParams>

    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public typealias FieldChoice = OneOf2<String, RepeatRef>

    /// An object defining properties of the legend.
    /// If `null`, the legend for the encoding channel will be removed.
    /// __Default value:__ If undefined, default [legend properties](https://vega.github.io/vega-lite/docs/legend.html) are applied.
    public typealias LegendChoice = OneOf2<Legend, ExplicitNull>

    /// An object defining properties of the channel's scale, which is the function that transforms values in the data domain (numbers, dates, strings, etc) to visual values (pixels, colors, sizes) of the encoding channels.
    /// If `null`, the scale will be [disabled and the data value will be directly encoded](https://vega.github.io/vega-lite/docs/scale.html#disable).
    /// __Default value:__ If undefined, default [scale properties](https://vega.github.io/vega-lite/docs/scale.html) are applied.
    public typealias ScaleChoice = OneOf2<Scale, ExplicitNull>

    /// Sort order for the encoded field.
    /// Supported `sort` values include `"ascending"`, `"descending"`, `null` (no sorting), or an array specifying the preferred order of values.
    /// For fields with discrete domains, `sort` can also be a [sort field definition object](https://vega.github.io/vega-lite/docs/sort.html#sort-field).
    /// For `sort` as an [array specifying the preferred order of values](https://vega.github.io/vega-lite/docs/sort.html#sort-array), the sort order will obey the values in the array, followed by any unspecified values in their original order.
    /// __Default value:__ `"ascending"`
    public typealias SortChoice = OneOf4<[String], SortOrder, EncodingSortField, ExplicitNull>

    public typealias Title = OneOf2<String, ExplicitNull>
}

public struct TopLevelVConcatSpec : Equatable, Codable {
    /// A list of views that should be concatenated and put into a column.
    public var vconcat: [Spec]
    /// URL to [JSON schema](http://json-schema.org/) for a Vega-Lite specification. Unless you have a reason to change this, use `https://vega.github.io/schema/vega-lite/v2.json`. Setting the `$schema` property allows automatic validation and autocomplete in editors that support JSON schema.
    public var schema: String?
    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public var autosize: AutosizeChoice?
    /// CSS color property to use as the background of visualization.
    /// __Default value:__ none (transparent)
    public var background: String?
    /// Vega-Lite configuration object.  This property can only be defined at the top-level of a specification.
    public var config: Config?
    /// An object describing the data source
    public var data: Data?
    /// A global data store for named datasets. This is a mapping from names to inline datasets.
    /// This can be an array of objects or primitive values or a string. Arrays of primitive values are ingested as objects with a `data` property.
    public var datasets: Datasets?
    /// Description of this mark for commenting purpose.
    public var description: String?
    /// Name of the visualization for later reference.
    public var name: String?
    /// The default visualization padding, in pixels, from the edge of the visualization canvas to the data rectangle.  If a number, specifies padding for all sides.
    /// If an object, the value should have the format `{"left": 5, "top": 5, "right": 5, "bottom": 5}` to specify padding for each side of the visualization.
    /// __Default value__: `5`
    public var padding: Padding?
    /// Scale, axis, and legend resolutions for vertically concatenated charts.
    public var resolve: Resolve?
    /// Title for the plot.
    public var title: TitleChoice?
    /// An array of data transformations such as filter and new field calculation.
    public var transform: [Transform]?

    public init(vconcat: [Spec] = [], schema: String? = .none, autosize: AutosizeChoice? = .none, background: String? = .none, config: Config? = .none, data: Data? = .none, datasets: Datasets? = .none, description: String? = .none, name: String? = .none, padding: Padding? = .none, resolve: Resolve? = .none, title: TitleChoice? = .none, transform: [Transform]? = .none) {
        self.vconcat = vconcat 
        self.schema = schema 
        self.autosize = autosize 
        self.background = background 
        self.config = config 
        self.data = data 
        self.datasets = datasets 
        self.description = description 
        self.name = name 
        self.padding = padding 
        self.resolve = resolve 
        self.title = title 
        self.transform = transform 
    }

    public enum CodingKeys : String, CodingKey {
        case vconcat
        case schema = "$schema"
        case autosize
        case background
        case config
        case data
        case datasets
        case description
        case name
        case padding
        case resolve
        case title
        case transform
    }

    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public typealias AutosizeChoice = OneOf2<AutosizeType, AutoSizeParams>

    /// Title for the plot.
    public typealias TitleChoice = OneOf2<String, TitleParams>
}

public struct MultiSelection : Equatable, Codable {
    public var type: `Type`
    /// By default, all data values are considered to lie within an empty selection.
    /// When set to `none`, empty selections contain no data values.
    public var empty: Empty?
    /// An array of encoding channels. The corresponding data field values
    /// must match for a data tuple to fall within the selection.
    public var encodings: [SingleDefChannel]?
    /// An array of field names whose values must match for a data tuple to
    /// fall within the selection.
    public var fields: [FieldsItem]?
    /// When true, an invisible voronoi diagram is computed to accelerate discrete
    /// selection. The data value _nearest_ the mouse cursor is added to the selection.
    /// See the [nearest transform](https://vega.github.io/vega-lite/docs/nearest.html) documentation for more information.
    public var nearest: Bool?
    /// A [Vega event stream](https://vega.github.io/vega/docs/event-streams/) (object or selector) that triggers the selection.
    /// For interval selections, the event stream must specify a [start and end](https://vega.github.io/vega/docs/event-streams/#between-filters).
    public var on: VgEventStream?
    /// With layered and multi-view displays, a strategy that determines how
    /// selections' data queries are resolved when applied in a filter transform,
    /// conditional encoding rule, or scale domain.
    public var resolve: SelectionResolution?
    /// Controls whether data values should be toggled or only ever inserted into
    /// multi selections. Can be `true`, `false` (for insertion only), or a
    /// [Vega expression](https://vega.github.io/vega/docs/expressions/).
    /// __Default value:__ `true`, which corresponds to `event.shiftKey` (i.e.,
    /// data values are toggled when a user interacts with the shift-key pressed).
    /// See the [toggle transform](https://vega.github.io/vega-lite/docs/toggle.html) documentation for more information.
    public var toggle: Toggle?

    public init(type: `Type` = .multi, empty: Empty? = .none, encodings: [SingleDefChannel]? = .none, fields: [FieldsItem]? = .none, nearest: Bool? = .none, on: VgEventStream? = .none, resolve: SelectionResolution? = .none, toggle: Toggle? = .none) {
        self.type = type 
        self.empty = empty 
        self.encodings = encodings 
        self.fields = fields 
        self.nearest = nearest 
        self.on = on 
        self.resolve = resolve 
        self.toggle = toggle 
    }

    public enum CodingKeys : String, CodingKey {
        case type
        case empty
        case encodings
        case fields
        case nearest
        case on
        case resolve
        case toggle
    }

    public enum `Type` : String, Equatable, Codable {
        case multi
    }

    /// By default, all data values are considered to lie within an empty selection.
    /// When set to `none`, empty selections contain no data values.
    public enum Empty : String, Equatable, Codable {
        case all
        case none
    }

    public typealias FieldsItem = String

    public typealias Toggle = OneOf2<String, Bool>
}

public struct ConditionalPredicateFieldDef : Equatable, Codable {
    public var test: LogicalOperandPredicate
    /// The encoded field's type of measurement (`"quantitative"`, `"temporal"`, `"ordinal"`, or `"nominal"`).
    /// It can also be a `"geojson"` type for encoding ['geoshape'](https://vega.github.io/vega-lite/docs/geoshape.html).
    public var type: `Type`
    /// Aggregation function for the field
    /// (e.g., `mean`, `sum`, `median`, `min`, `max`, `count`).
    /// __Default value:__ `undefined` (None)
    public var aggregate: Aggregate?
    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public var bin: BinChoice?
    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public var field: FieldChoice?
    /// Time unit (e.g., `year`, `yearmonth`, `month`, `hours`) for a temporal field.
    /// or [a temporal field that gets casted as ordinal](https://vega.github.io/vega-lite/docs/type.html#cast).
    /// __Default value:__ `undefined` (None)
    public var timeUnit: TimeUnit?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?

    public init(test: LogicalOperandPredicate, type: `Type`, aggregate: Aggregate? = .none, bin: BinChoice? = .none, field: FieldChoice? = .none, timeUnit: TimeUnit? = .none, title: Title? = .none) {
        self.test = test 
        self.type = type 
        self.aggregate = aggregate 
        self.bin = bin 
        self.field = field 
        self.timeUnit = timeUnit 
        self.title = title 
    }

    public enum CodingKeys : String, CodingKey {
        case test
        case type
        case aggregate
        case bin
        case field
        case timeUnit
        case title
    }

    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public typealias BinChoice = OneOf2<Bool, BinParams>

    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public typealias FieldChoice = OneOf2<String, RepeatRef>

    public typealias Title = OneOf2<String, ExplicitNull>
}

/// A ValueDef with Condition<ValueDef | FieldDef>
/// {
///    condition: {field: ...} | {value: ...},
///    value: ...,
/// }
public struct TextValueDefWithCondition : Equatable, Codable {
    /// A field definition or one or more value definition(s) with a selection predicate.
    public var condition: ConditionChoice?
    /// A constant value in visual domain.
    public var value: Value?

    public init(condition: ConditionChoice? = .none, value: Value? = .none) {
        self.condition = condition 
        self.value = value 
    }

    public enum CodingKeys : String, CodingKey {
        case condition
        case value
    }

    /// A field definition or one or more value definition(s) with a selection predicate.
    public typealias ConditionChoice = OneOf3<ConditionalTextFieldDef, ConditionalValueDef, [ConditionalValueDef]>

    /// A ValueDef with Condition<ValueDef | FieldDef>
    /// {
    ///    condition: {field: ...} | {value: ...},
    ///    value: ...,
    /// }
    public typealias Value = OneOf3<Double, String, Bool>
}

public struct FieldGTEPredicate : Equatable, Codable {
    /// Field to be filtered.
    public var field: String
    /// The value that the field should be greater than or equals to.
    public var gte: GteChoice
    /// Time unit for the field to be filtered.
    public var timeUnit: TimeUnit?

    public init(field: String, gte: GteChoice, timeUnit: TimeUnit? = .none) {
        self.field = field 
        self.gte = gte 
        self.timeUnit = timeUnit 
    }

    public enum CodingKeys : String, CodingKey {
        case field
        case gte
        case timeUnit
    }

    /// The value that the field should be greater than or equals to.
    public typealias GteChoice = OneOf3<String, Double, DateTime>
}

public struct TextConfig : Equatable, Codable {
    /// The horizontal alignment of the text. One of `"left"`, `"right"`, `"center"`.
    public var align: HorizontalAlign?
    /// The rotation angle of the text, in degrees.
    public var angle: Double?
    /// The vertical alignment of the text. One of `"top"`, `"middle"`, `"bottom"`.
    /// __Default value:__ `"middle"`
    public var baseline: VerticalAlign?
    /// Default color.  Note that `fill` and `stroke` have higher precedence than `color` and will override `color`.
    /// __Default value:__ <span style="color: #4682b4;">&#9632;</span> `"#4682b4"`
    /// __Note:__ This property cannot be used in a [style config](https://vega.github.io/vega-lite/docs/mark.html#style-config).
    public var color: String?
    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public var cursor: Cursor?
    /// The horizontal offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dx: Double?
    /// The vertical offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dy: Double?
    /// Default Fill Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var fill: String?
    /// The fill opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var fillOpacity: Double?
    /// Whether the mark's color should be used as fill color instead of stroke color.
    /// __Default value:__ `true` for all marks except `point` and `false` for `point`.
    /// __Applicable for:__ `bar`, `point`, `circle`, `square`, and `area` marks.
    /// __Note:__ This property cannot be used in a [style config](https://vega.github.io/vega-lite/docs/mark.html#style-config).
    public var filled: Bool?
    /// The typeface to set the text in (e.g., `"Helvetica Neue"`).
    public var font: String?
    /// The font size, in pixels.
    public var fontSize: Double?
    /// The font style (e.g., `"italic"`).
    public var fontStyle: FontStyle?
    /// The font weight.
    /// This can be either a string (e.g `"bold"`, `"normal"`) or a number (`100`, `200`, `300`, ..., `900` where `"normal"` = `400` and `"bold"` = `700`).
    public var fontWeight: FontWeight?
    /// A URL to load upon mouse click. If defined, the mark acts as a hyperlink.
    public var href: String?
    /// The line interpolation method to use for line and area marks. One of the following:
    /// - `"linear"`: piecewise linear segments, as in a polyline.
    /// - `"linear-closed"`: close the linear segments to form a polygon.
    /// - `"step"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"step-before"`: alternate between vertical and horizontal segments, as in a step function.
    /// - `"step-after"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"basis"`: a B-spline, with control point duplication on the ends.
    /// - `"basis-open"`: an open B-spline; may not intersect the start or end.
    /// - `"basis-closed"`: a closed B-spline, as in a loop.
    /// - `"cardinal"`: a Cardinal spline, with control point duplication on the ends.
    /// - `"cardinal-open"`: an open Cardinal spline; may not intersect the start or end, but will intersect other control points.
    /// - `"cardinal-closed"`: a closed Cardinal spline, as in a loop.
    /// - `"bundle"`: equivalent to basis, except the tension parameter is used to straighten the spline.
    /// - `"monotone"`: cubic interpolation that preserves monotonicity in y.
    public var interpolate: Interpolate?
    /// The maximum length of the text mark in pixels (default 0, indicating no limit). The text value will be automatically truncated if the rendered size exceeds the limit.
    public var limit: Double?
    /// The overall opacity (value between [0,1]).
    /// __Default value:__ `0.7` for non-aggregate plots with `point`, `tick`, `circle`, or `square` marks or layered `bar` charts and `1` otherwise.
    public var opacity: Double?
    /// The orientation of a non-stacked bar, tick, area, and line charts.
    /// The value is either horizontal (default) or vertical.
    /// - For bar, rule and tick, this determines whether the size of the bar and tick
    /// should be applied to x or y dimension.
    /// - For area, this property determines the orient property of the Vega output.
    /// - For line and trail marks, this property determines the sort order of the points in the line
    /// if `config.sortLineBy` is not specified.
    /// For stacked charts, this is always determined by the orientation of the stack;
    /// therefore explicitly specified value will be ignored.
    public var orient: Orient?
    /// Polar coordinate radial offset, in pixels, of the text label from the origin determined by the `x` and `y` properties.
    public var radius: Double?
    /// The default symbol shape to use. One of: `"circle"` (default), `"square"`, `"cross"`, `"diamond"`, `"triangle-up"`, or `"triangle-down"`, or a custom SVG path.
    /// __Default value:__ `"circle"`
    public var shape: String?
    /// Whether month names and weekday names should be abbreviated.
    public var shortTimeLabels: Bool?
    /// The pixel area each the point/circle/square.
    /// For example: in the case of circles, the radius is determined in part by the square root of the size value.
    /// __Default value:__ `30`
    public var size: Double?
    /// Default Stroke Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var stroke: String?
    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public var strokeCap: StrokeCap?
    /// An array of alternating stroke, space lengths for creating dashed or dotted lines.
    public var strokeDash: [StrokeDashItem]?
    /// The offset (in pixels) into which to begin drawing with the stroke dash array.
    public var strokeDashOffset: Double?
    /// The stroke opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var strokeOpacity: Double?
    /// The stroke width, in pixels.
    public var strokeWidth: Double?
    /// Depending on the interpolation type, sets the tension parameter (for line and area marks).
    public var tension: Double?
    /// Placeholder text if the `text` channel is not specified
    public var text: String?
    /// Polar coordinate angle, in radians, of the text label from the origin determined by the `x` and `y` properties. Values for `theta` follow the same convention of `arc` mark `startAngle` and `endAngle` properties: angles are measured in radians, with `0` indicating "north".
    public var theta: Double?

    public init(align: HorizontalAlign? = .none, angle: Double? = .none, baseline: VerticalAlign? = .none, color: String? = .none, cursor: Cursor? = .none, dx: Double? = .none, dy: Double? = .none, fill: String? = .none, fillOpacity: Double? = .none, filled: Bool? = .none, font: String? = .none, fontSize: Double? = .none, fontStyle: FontStyle? = .none, fontWeight: FontWeight? = .none, href: String? = .none, interpolate: Interpolate? = .none, limit: Double? = .none, opacity: Double? = .none, orient: Orient? = .none, radius: Double? = .none, shape: String? = .none, shortTimeLabels: Bool? = .none, size: Double? = .none, stroke: String? = .none, strokeCap: StrokeCap? = .none, strokeDash: [StrokeDashItem]? = .none, strokeDashOffset: Double? = .none, strokeOpacity: Double? = .none, strokeWidth: Double? = .none, tension: Double? = .none, text: String? = .none, theta: Double? = .none) {
        self.align = align 
        self.angle = angle 
        self.baseline = baseline 
        self.color = color 
        self.cursor = cursor 
        self.dx = dx 
        self.dy = dy 
        self.fill = fill 
        self.fillOpacity = fillOpacity 
        self.filled = filled 
        self.font = font 
        self.fontSize = fontSize 
        self.fontStyle = fontStyle 
        self.fontWeight = fontWeight 
        self.href = href 
        self.interpolate = interpolate 
        self.limit = limit 
        self.opacity = opacity 
        self.orient = orient 
        self.radius = radius 
        self.shape = shape 
        self.shortTimeLabels = shortTimeLabels 
        self.size = size 
        self.stroke = stroke 
        self.strokeCap = strokeCap 
        self.strokeDash = strokeDash 
        self.strokeDashOffset = strokeDashOffset 
        self.strokeOpacity = strokeOpacity 
        self.strokeWidth = strokeWidth 
        self.tension = tension 
        self.text = text 
        self.theta = theta 
    }

    public enum CodingKeys : String, CodingKey {
        case align
        case angle
        case baseline
        case color
        case cursor
        case dx
        case dy
        case fill
        case fillOpacity
        case filled
        case font
        case fontSize
        case fontStyle
        case fontWeight
        case href
        case interpolate
        case limit
        case opacity
        case orient
        case radius
        case shape
        case shortTimeLabels
        case size
        case stroke
        case strokeCap
        case strokeDash
        case strokeDashOffset
        case strokeOpacity
        case strokeWidth
        case tension
        case text
        case theta
    }

    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public enum Cursor : String, Equatable, Codable {
        case auto
        case `default` = "default"
        case none
        case contextMenu = "context-menu"
        case help
        case pointer
        case progress
        case wait
        case cell
        case crosshair
        case text
        case verticalText = "vertical-text"
        case alias
        case copy
        case move
        case noDrop = "no-drop"
        case notAllowed = "not-allowed"
        case eResize = "e-resize"
        case nResize = "n-resize"
        case neResize = "ne-resize"
        case nwResize = "nw-resize"
        case sResize = "s-resize"
        case seResize = "se-resize"
        case swResize = "sw-resize"
        case wResize = "w-resize"
        case ewResize = "ew-resize"
        case nsResize = "ns-resize"
        case neswResize = "nesw-resize"
        case nwseResize = "nwse-resize"
        case colResize = "col-resize"
        case rowResize = "row-resize"
        case allScroll = "all-scroll"
        case zoomIn = "zoom-in"
        case zoomOut = "zoom-out"
        case grab
        case grabbing
    }

    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public enum StrokeCap : String, Equatable, Codable {
        case butt
        case round
        case square
    }

    public typealias StrokeDashItem = Double
}

public struct IntervalSelectionConfig : Equatable, Codable {
    /// Establishes a two-way binding between the interval selection and the scales
    /// used within the same view. This allows a user to interactively pan and
    /// zoom the view.
    public var bind: Bind?
    /// By default, all data values are considered to lie within an empty selection.
    /// When set to `none`, empty selections contain no data values.
    public var empty: Empty?
    /// An array of encoding channels. The corresponding data field values
    /// must match for a data tuple to fall within the selection.
    public var encodings: [SingleDefChannel]?
    /// An array of field names whose values must match for a data tuple to
    /// fall within the selection.
    public var fields: [FieldsItem]?
    /// An interval selection also adds a rectangle mark to depict the
    /// extents of the interval. The `mark` property can be used to customize the
    /// appearance of the mark.
    public var mark: BrushConfig?
    /// A [Vega event stream](https://vega.github.io/vega/docs/event-streams/) (object or selector) that triggers the selection.
    /// For interval selections, the event stream must specify a [start and end](https://vega.github.io/vega/docs/event-streams/#between-filters).
    public var on: VgEventStream?
    /// With layered and multi-view displays, a strategy that determines how
    /// selections' data queries are resolved when applied in a filter transform,
    /// conditional encoding rule, or scale domain.
    public var resolve: SelectionResolution?
    /// When truthy, allows a user to interactively move an interval selection
    /// back-and-forth. Can be `true`, `false` (to disable panning), or a
    /// [Vega event stream definition](https://vega.github.io/vega/docs/event-streams/)
    /// which must include a start and end event to trigger continuous panning.
    /// __Default value:__ `true`, which corresponds to
    /// `[mousedown, window:mouseup] > window:mousemove!` which corresponds to
    /// clicks and dragging within an interval selection to reposition it.
    public var translate: Translate?
    /// When truthy, allows a user to interactively resize an interval selection.
    /// Can be `true`, `false` (to disable zooming), or a [Vega event stream
    /// definition](https://vega.github.io/vega/docs/event-streams/). Currently,
    /// only `wheel` events are supported.
    /// __Default value:__ `true`, which corresponds to `wheel!`.
    public var zoom: Zoom?

    public init(bind: Bind? = .none, empty: Empty? = .none, encodings: [SingleDefChannel]? = .none, fields: [FieldsItem]? = .none, mark: BrushConfig? = .none, on: VgEventStream? = .none, resolve: SelectionResolution? = .none, translate: Translate? = .none, zoom: Zoom? = .none) {
        self.bind = bind 
        self.empty = empty 
        self.encodings = encodings 
        self.fields = fields 
        self.mark = mark 
        self.on = on 
        self.resolve = resolve 
        self.translate = translate 
        self.zoom = zoom 
    }

    public enum CodingKeys : String, CodingKey {
        case bind
        case empty
        case encodings
        case fields
        case mark
        case on
        case resolve
        case translate
        case zoom
    }

    /// Establishes a two-way binding between the interval selection and the scales
    /// used within the same view. This allows a user to interactively pan and
    /// zoom the view.
    public enum Bind : String, Equatable, Codable {
        case scales
    }

    /// By default, all data values are considered to lie within an empty selection.
    /// When set to `none`, empty selections contain no data values.
    public enum Empty : String, Equatable, Codable {
        case all
        case none
    }

    public typealias FieldsItem = String

    public typealias Translate = OneOf2<String, Bool>

    public typealias Zoom = OneOf2<String, Bool>
}

public struct ConditionalSelectionValueDef : Equatable, Codable {
    /// A [selection name](https://vega.github.io/vega-lite/docs/selection.html), or a series of [composed selections](https://vega.github.io/vega-lite/docs/selection.html#compose).
    public var selection: SelectionOperand
    /// A constant value in visual domain (e.g., `"red"` / "#0099ff" for color, values between `0` to `1` for opacity).
    public var value: Value

    public init(selection: SelectionOperand, value: Value) {
        self.selection = selection 
        self.value = value 
    }

    public enum CodingKeys : String, CodingKey {
        case selection
        case value
    }

    public typealias Value = OneOf3<Double, String, Bool>
}

public struct MarkDef : Equatable, Codable {
    /// The mark type.
    /// One of `"bar"`, `"circle"`, `"square"`, `"tick"`, `"line"`,
    /// `"area"`, `"point"`, `"geoshape"`, `"rule"`, and `"text"`.
    public var type: Mark
    /// The horizontal alignment of the text. One of `"left"`, `"right"`, `"center"`.
    public var align: HorizontalAlign?
    /// The rotation angle of the text, in degrees.
    public var angle: Double?
    /// The vertical alignment of the text. One of `"top"`, `"middle"`, `"bottom"`.
    /// __Default value:__ `"middle"`
    public var baseline: VerticalAlign?
    /// Offset between bars for binned field.  Ideal value for this is either 0 (Preferred by statisticians) or 1 (Vega-Lite Default, D3 example style).
    /// __Default value:__ `1`
    public var binSpacing: Double?
    /// Whether a mark be clipped to the enclosing group’s width and height.
    public var clip: Bool?
    /// Default color.  Note that `fill` and `stroke` have higher precedence than `color` and will override `color`.
    /// __Default value:__ <span style="color: #4682b4;">&#9632;</span> `"#4682b4"`
    /// __Note:__ This property cannot be used in a [style config](https://vega.github.io/vega-lite/docs/mark.html#style-config).
    public var color: String?
    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public var cursor: Cursor?
    /// The horizontal offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dx: Double?
    /// The vertical offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dy: Double?
    /// Default Fill Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var fill: String?
    /// The fill opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var fillOpacity: Double?
    /// Whether the mark's color should be used as fill color instead of stroke color.
    /// __Default value:__ `true` for all marks except `point` and `false` for `point`.
    /// __Applicable for:__ `bar`, `point`, `circle`, `square`, and `area` marks.
    /// __Note:__ This property cannot be used in a [style config](https://vega.github.io/vega-lite/docs/mark.html#style-config).
    public var filled: Bool?
    /// The typeface to set the text in (e.g., `"Helvetica Neue"`).
    public var font: String?
    /// The font size, in pixels.
    public var fontSize: Double?
    /// The font style (e.g., `"italic"`).
    public var fontStyle: FontStyle?
    /// The font weight.
    /// This can be either a string (e.g `"bold"`, `"normal"`) or a number (`100`, `200`, `300`, ..., `900` where `"normal"` = `400` and `"bold"` = `700`).
    public var fontWeight: FontWeight?
    /// A URL to load upon mouse click. If defined, the mark acts as a hyperlink.
    public var href: String?
    /// The line interpolation method to use for line and area marks. One of the following:
    /// - `"linear"`: piecewise linear segments, as in a polyline.
    /// - `"linear-closed"`: close the linear segments to form a polygon.
    /// - `"step"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"step-before"`: alternate between vertical and horizontal segments, as in a step function.
    /// - `"step-after"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"basis"`: a B-spline, with control point duplication on the ends.
    /// - `"basis-open"`: an open B-spline; may not intersect the start or end.
    /// - `"basis-closed"`: a closed B-spline, as in a loop.
    /// - `"cardinal"`: a Cardinal spline, with control point duplication on the ends.
    /// - `"cardinal-open"`: an open Cardinal spline; may not intersect the start or end, but will intersect other control points.
    /// - `"cardinal-closed"`: a closed Cardinal spline, as in a loop.
    /// - `"bundle"`: equivalent to basis, except the tension parameter is used to straighten the spline.
    /// - `"monotone"`: cubic interpolation that preserves monotonicity in y.
    public var interpolate: Interpolate?
    /// The maximum length of the text mark in pixels (default 0, indicating no limit). The text value will be automatically truncated if the rendered size exceeds the limit.
    public var limit: Double?
    /// A flag for overlaying line on top of area marks, or an object defining the properties of the overlayed lines.
    /// - If this value is an empty object (`{}`) or `true`, lines with default properties will be used.
    /// - If this value is `false`, no lines would be automatically added to area marks.
    /// __Default value:__ `false`.
    public var line: LineChoice?
    /// The overall opacity (value between [0,1]).
    /// __Default value:__ `0.7` for non-aggregate plots with `point`, `tick`, `circle`, or `square` marks or layered `bar` charts and `1` otherwise.
    public var opacity: Double?
    /// The orientation of a non-stacked bar, tick, area, and line charts.
    /// The value is either horizontal (default) or vertical.
    /// - For bar, rule and tick, this determines whether the size of the bar and tick
    /// should be applied to x or y dimension.
    /// - For area, this property determines the orient property of the Vega output.
    /// - For line and trail marks, this property determines the sort order of the points in the line
    /// if `config.sortLineBy` is not specified.
    /// For stacked charts, this is always determined by the orientation of the stack;
    /// therefore explicitly specified value will be ignored.
    public var orient: Orient?
    /// A flag for overlaying points on top of line or area marks, or an object defining the properties of the overlayed points.
    /// - If this property is `"transparent"`, transparent points will be used (for enhancing tooltips and selections).
    /// - If this property is an empty object (`{}`) or `true`, filled points with default properties will be used.
    /// - If this property is `false`, no points would be automatically added to line or area marks.
    /// __Default value:__ `false`.
    public var point: PointChoice?
    /// Polar coordinate radial offset, in pixels, of the text label from the origin determined by the `x` and `y` properties.
    public var radius: Double?
    /// The default symbol shape to use. One of: `"circle"` (default), `"square"`, `"cross"`, `"diamond"`, `"triangle-up"`, or `"triangle-down"`, or a custom SVG path.
    /// __Default value:__ `"circle"`
    public var shape: String?
    /// The pixel area each the point/circle/square.
    /// For example: in the case of circles, the radius is determined in part by the square root of the size value.
    /// __Default value:__ `30`
    public var size: Double?
    /// Default Stroke Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var stroke: String?
    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public var strokeCap: StrokeCap?
    /// An array of alternating stroke, space lengths for creating dashed or dotted lines.
    public var strokeDash: [StrokeDashItem]?
    /// The offset (in pixels) into which to begin drawing with the stroke dash array.
    public var strokeDashOffset: Double?
    /// The stroke opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var strokeOpacity: Double?
    /// The stroke width, in pixels.
    public var strokeWidth: Double?
    /// A string or array of strings indicating the name of custom styles to apply to the mark. A style is a named collection of mark property defaults defined within the [style configuration](https://vega.github.io/vega-lite/docs/mark.html#style-config). If style is an array, later styles will override earlier styles. Any [mark properties](https://vega.github.io/vega-lite/docs/encoding.html#mark-prop) explicitly defined within the `encoding` will override a style default.
    /// __Default value:__ The mark's name.  For example, a bar mark will have style `"bar"` by default.
    /// __Note:__ Any specified style will augment the default style. For example, a bar mark with `"style": "foo"` will receive from `config.style.bar` and `config.style.foo` (the specified style `"foo"` has higher precedence).
    public var style: StyleChoice?
    /// Depending on the interpolation type, sets the tension parameter (for line and area marks).
    public var tension: Double?
    /// Placeholder text if the `text` channel is not specified
    public var text: String?
    /// Polar coordinate angle, in radians, of the text label from the origin determined by the `x` and `y` properties. Values for `theta` follow the same convention of `arc` mark `startAngle` and `endAngle` properties: angles are measured in radians, with `0` indicating "north".
    public var theta: Double?
    /// Thickness of the tick mark.
    /// __Default value:__  `1`
    public var thickness: Double?
    /// Offset for x2-position.
    public var x2Offset: Double?
    /// Offset for x-position.
    public var xOffset: Double?
    /// Offset for y2-position.
    public var y2Offset: Double?
    /// Offset for y-position.
    public var yOffset: Double?

    public init(type: Mark, align: HorizontalAlign? = .none, angle: Double? = .none, baseline: VerticalAlign? = .none, binSpacing: Double? = .none, clip: Bool? = .none, color: String? = .none, cursor: Cursor? = .none, dx: Double? = .none, dy: Double? = .none, fill: String? = .none, fillOpacity: Double? = .none, filled: Bool? = .none, font: String? = .none, fontSize: Double? = .none, fontStyle: FontStyle? = .none, fontWeight: FontWeight? = .none, href: String? = .none, interpolate: Interpolate? = .none, limit: Double? = .none, line: LineChoice? = .none, opacity: Double? = .none, orient: Orient? = .none, point: PointChoice? = .none, radius: Double? = .none, shape: String? = .none, size: Double? = .none, stroke: String? = .none, strokeCap: StrokeCap? = .none, strokeDash: [StrokeDashItem]? = .none, strokeDashOffset: Double? = .none, strokeOpacity: Double? = .none, strokeWidth: Double? = .none, style: StyleChoice? = .none, tension: Double? = .none, text: String? = .none, theta: Double? = .none, thickness: Double? = .none, x2Offset: Double? = .none, xOffset: Double? = .none, y2Offset: Double? = .none, yOffset: Double? = .none) {
        self.type = type 
        self.align = align 
        self.angle = angle 
        self.baseline = baseline 
        self.binSpacing = binSpacing 
        self.clip = clip 
        self.color = color 
        self.cursor = cursor 
        self.dx = dx 
        self.dy = dy 
        self.fill = fill 
        self.fillOpacity = fillOpacity 
        self.filled = filled 
        self.font = font 
        self.fontSize = fontSize 
        self.fontStyle = fontStyle 
        self.fontWeight = fontWeight 
        self.href = href 
        self.interpolate = interpolate 
        self.limit = limit 
        self.line = line 
        self.opacity = opacity 
        self.orient = orient 
        self.point = point 
        self.radius = radius 
        self.shape = shape 
        self.size = size 
        self.stroke = stroke 
        self.strokeCap = strokeCap 
        self.strokeDash = strokeDash 
        self.strokeDashOffset = strokeDashOffset 
        self.strokeOpacity = strokeOpacity 
        self.strokeWidth = strokeWidth 
        self.style = style 
        self.tension = tension 
        self.text = text 
        self.theta = theta 
        self.thickness = thickness 
        self.x2Offset = x2Offset 
        self.xOffset = xOffset 
        self.y2Offset = y2Offset 
        self.yOffset = yOffset 
    }

    public enum CodingKeys : String, CodingKey {
        case type
        case align
        case angle
        case baseline
        case binSpacing
        case clip
        case color
        case cursor
        case dx
        case dy
        case fill
        case fillOpacity
        case filled
        case font
        case fontSize
        case fontStyle
        case fontWeight
        case href
        case interpolate
        case limit
        case line
        case opacity
        case orient
        case point
        case radius
        case shape
        case size
        case stroke
        case strokeCap
        case strokeDash
        case strokeDashOffset
        case strokeOpacity
        case strokeWidth
        case style
        case tension
        case text
        case theta
        case thickness
        case x2Offset
        case xOffset
        case y2Offset
        case yOffset
    }

    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public enum Cursor : String, Equatable, Codable {
        case auto
        case `default` = "default"
        case none
        case contextMenu = "context-menu"
        case help
        case pointer
        case progress
        case wait
        case cell
        case crosshair
        case text
        case verticalText = "vertical-text"
        case alias
        case copy
        case move
        case noDrop = "no-drop"
        case notAllowed = "not-allowed"
        case eResize = "e-resize"
        case nResize = "n-resize"
        case neResize = "ne-resize"
        case nwResize = "nw-resize"
        case sResize = "s-resize"
        case seResize = "se-resize"
        case swResize = "sw-resize"
        case wResize = "w-resize"
        case ewResize = "ew-resize"
        case nsResize = "ns-resize"
        case neswResize = "nesw-resize"
        case nwseResize = "nwse-resize"
        case colResize = "col-resize"
        case rowResize = "row-resize"
        case allScroll = "all-scroll"
        case zoomIn = "zoom-in"
        case zoomOut = "zoom-out"
        case grab
        case grabbing
    }

    /// A flag for overlaying line on top of area marks, or an object defining the properties of the overlayed lines.
    /// - If this value is an empty object (`{}`) or `true`, lines with default properties will be used.
    /// - If this value is `false`, no lines would be automatically added to area marks.
    /// __Default value:__ `false`.
    public typealias LineChoice = OneOf2<Bool, MarkConfig>

    /// A flag for overlaying points on top of line or area marks, or an object defining the properties of the overlayed points.
    /// - If this property is `"transparent"`, transparent points will be used (for enhancing tooltips and selections).
    /// - If this property is an empty object (`{}`) or `true`, filled points with default properties will be used.
    /// - If this property is `false`, no points would be automatically added to line or area marks.
    /// __Default value:__ `false`.
    public typealias PointChoice = PointTypes.Choice
    public enum PointTypes {

        public typealias Choice = OneOf3<Bool, MarkConfig, Type3>

        public enum Type3 : String, Equatable, Codable {
            case transparent
        }
    }

    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public enum StrokeCap : String, Equatable, Codable {
        case butt
        case round
        case square
    }

    public typealias StrokeDashItem = Double

    /// A string or array of strings indicating the name of custom styles to apply to the mark. A style is a named collection of mark property defaults defined within the [style configuration](https://vega.github.io/vega-lite/docs/mark.html#style-config). If style is an array, later styles will override earlier styles. Any [mark properties](https://vega.github.io/vega-lite/docs/encoding.html#mark-prop) explicitly defined within the `encoding` will override a style default.
    /// __Default value:__ The mark's name.  For example, a bar mark will have style `"bar"` by default.
    /// __Note:__ Any specified style will augment the default style. For example, a bar mark with `"style": "foo"` will receive from `config.style.bar` and `config.style.foo` (the specified style `"foo"` has higher precedence).
    public typealias StyleChoice = OneOf2<String, [String]>
}

public struct AxisResolveMap : Equatable, Codable {
    public var x: ResolveMode?
    public var y: ResolveMode?

    public init(x: ResolveMode? = .none, y: ResolveMode? = .none) {
        self.x = x 
        self.y = y 
    }

    public enum CodingKeys : String, CodingKey {
        case x
        case y
    }
}

public enum UtcMultiTimeUnit : String, Equatable, Codable {
    case utcyearquarter
    case utcyearquartermonth
    case utcyearmonth
    case utcyearmonthdate
    case utcyearmonthdatehours
    case utcyearmonthdatehoursminutes
    case utcyearmonthdatehoursminutesseconds
    case utcquartermonth
    case utcmonthdate
    case utchoursminutes
    case utchoursminutesseconds
    case utcminutesseconds
    case utcsecondsmilliseconds
}

public struct VgGenericBinding : Equatable, Codable {
    public var input: String
    public var element: String?

    public init(input: String, element: String? = .none) {
        self.input = input 
        self.element = element 
    }

    public enum CodingKeys : String, CodingKey {
        case input
        case element
    }
}

public struct VgAxisConfig : Equatable, Codable {
    /// An interpolation fraction indicating where, for `band` scales, axis ticks should be positioned. A value of `0` places ticks at the left edge of their bands. A value of `0.5` places ticks in the middle of their bands.
    public var bandPosition: Double?
    /// A boolean flag indicating if the domain (the axis baseline) should be included as part of the axis.
    /// __Default value:__ `true`
    public var domain: Bool?
    /// Color of axis domain line.
    /// __Default value:__  (none, using Vega default).
    public var domainColor: String?
    /// Stroke width of axis domain line
    /// __Default value:__  (none, using Vega default).
    public var domainWidth: Double?
    /// A boolean flag indicating if grid lines should be included as part of the axis
    /// __Default value:__ `true` for [continuous scales](https://vega.github.io/vega-lite/docs/scale.html#continuous) that are not binned; otherwise, `false`.
    public var grid: Bool?
    /// Color of gridlines.
    public var gridColor: String?
    /// The offset (in pixels) into which to begin drawing with the grid dash array.
    public var gridDash: [GridDashItem]?
    /// The stroke opacity of grid (value between [0,1])
    /// __Default value:__ (`1` by default)
    public var gridOpacity: Double?
    /// The grid width, in pixels.
    public var gridWidth: Double?
    /// The rotation angle of the axis labels.
    /// __Default value:__ `-90` for nominal and ordinal fields; `0` otherwise.
    public var labelAngle: Double?
    /// Indicates if labels should be hidden if they exceed the axis range. If `false `(the default) no bounds overlap analysis is performed. If `true`, labels will be hidden if they exceed the axis range by more than 1 pixel. If this property is a number, it specifies the pixel tolerance: the maximum amount by which a label bounding box may exceed the axis range.
    /// __Default value:__ `false`.
    public var labelBound: LabelBound?
    /// The color of the tick label, can be in hex color code or regular color name.
    public var labelColor: String?
    /// Indicates if the first and last axis labels should be aligned flush with the scale range. Flush alignment for a horizontal axis will left-align the first label and right-align the last label. For vertical axes, bottom and top text baselines are applied instead. If this property is a number, it also indicates the number of pixels by which to offset the first and last labels; for example, a value of 2 will flush-align the first and last labels and also push them 2 pixels outward from the center of the axis. The additional adjustment can sometimes help the labels better visually group with corresponding axis ticks.
    /// __Default value:__ `true` for axis of a continuous x-scale. Otherwise, `false`.
    public var labelFlush: LabelFlush?
    /// The font of the tick label.
    public var labelFont: String?
    /// The font size of the label, in pixels.
    public var labelFontSize: Double?
    /// Maximum allowed pixel width of axis tick labels.
    public var labelLimit: Double?
    /// The strategy to use for resolving overlap of axis labels. If `false` (the default), no overlap reduction is attempted. If set to `true` or `"parity"`, a strategy of removing every other label is used (this works well for standard linear axes). If set to `"greedy"`, a linear scan of the labels is performed, removing any labels that overlaps with the last visible label (this often works better for log-scaled axes).
    /// __Default value:__ `true` for non-nominal fields with non-log scales; `"greedy"` for log scales; otherwise `false`.
    public var labelOverlap: LabelOverlapChoice?
    /// The padding, in pixels, between axis and text labels.
    public var labelPadding: Double?
    /// A boolean flag indicating if labels should be included as part of the axis.
    /// __Default value:__  `true`.
    public var labels: Bool?
    /// The maximum extent in pixels that axis ticks and labels should use. This determines a maximum offset value for axis titles.
    /// __Default value:__ `undefined`.
    public var maxExtent: Double?
    /// The minimum extent in pixels that axis ticks and labels should use. This determines a minimum offset value for axis titles.
    /// __Default value:__ `30` for y-axis; `undefined` for x-axis.
    public var minExtent: Double?
    /// The color of the axis's tick.
    public var tickColor: String?
    /// Boolean flag indicating if pixel position values should be rounded to the nearest integer.
    public var tickRound: Bool?
    /// The size in pixels of axis ticks.
    public var tickSize: Double?
    /// The width, in pixels, of ticks.
    public var tickWidth: Double?
    /// Boolean value that determines whether the axis should include ticks.
    public var ticks: Bool?
    /// Horizontal text alignment of axis titles.
    public var titleAlign: String?
    /// Angle in degrees of axis titles.
    public var titleAngle: Double?
    /// Vertical text baseline for axis titles.
    public var titleBaseline: String?
    /// Color of the title, can be in hex color code or regular color name.
    public var titleColor: String?
    /// Font of the title. (e.g., `"Helvetica Neue"`).
    public var titleFont: String?
    /// Font size of the title.
    public var titleFontSize: Double?
    /// Font weight of the title.
    /// This can be either a string (e.g `"bold"`, `"normal"`) or a number (`100`, `200`, `300`, ..., `900` where `"normal"` = `400` and `"bold"` = `700`).
    public var titleFontWeight: FontWeight?
    /// Maximum allowed pixel width of axis titles.
    public var titleLimit: Double?
    /// Max length for axis title if the title is automatically generated from the field's description.
    public var titleMaxLength: Double?
    /// The padding, in pixels, between title and axis.
    public var titlePadding: Double?
    /// X-coordinate of the axis title relative to the axis group.
    public var titleX: Double?
    /// Y-coordinate of the axis title relative to the axis group.
    public var titleY: Double?

    public init(bandPosition: Double? = .none, domain: Bool? = .none, domainColor: String? = .none, domainWidth: Double? = .none, grid: Bool? = .none, gridColor: String? = .none, gridDash: [GridDashItem]? = .none, gridOpacity: Double? = .none, gridWidth: Double? = .none, labelAngle: Double? = .none, labelBound: LabelBound? = .none, labelColor: String? = .none, labelFlush: LabelFlush? = .none, labelFont: String? = .none, labelFontSize: Double? = .none, labelLimit: Double? = .none, labelOverlap: LabelOverlapChoice? = .none, labelPadding: Double? = .none, labels: Bool? = .none, maxExtent: Double? = .none, minExtent: Double? = .none, tickColor: String? = .none, tickRound: Bool? = .none, tickSize: Double? = .none, tickWidth: Double? = .none, ticks: Bool? = .none, titleAlign: String? = .none, titleAngle: Double? = .none, titleBaseline: String? = .none, titleColor: String? = .none, titleFont: String? = .none, titleFontSize: Double? = .none, titleFontWeight: FontWeight? = .none, titleLimit: Double? = .none, titleMaxLength: Double? = .none, titlePadding: Double? = .none, titleX: Double? = .none, titleY: Double? = .none) {
        self.bandPosition = bandPosition 
        self.domain = domain 
        self.domainColor = domainColor 
        self.domainWidth = domainWidth 
        self.grid = grid 
        self.gridColor = gridColor 
        self.gridDash = gridDash 
        self.gridOpacity = gridOpacity 
        self.gridWidth = gridWidth 
        self.labelAngle = labelAngle 
        self.labelBound = labelBound 
        self.labelColor = labelColor 
        self.labelFlush = labelFlush 
        self.labelFont = labelFont 
        self.labelFontSize = labelFontSize 
        self.labelLimit = labelLimit 
        self.labelOverlap = labelOverlap 
        self.labelPadding = labelPadding 
        self.labels = labels 
        self.maxExtent = maxExtent 
        self.minExtent = minExtent 
        self.tickColor = tickColor 
        self.tickRound = tickRound 
        self.tickSize = tickSize 
        self.tickWidth = tickWidth 
        self.ticks = ticks 
        self.titleAlign = titleAlign 
        self.titleAngle = titleAngle 
        self.titleBaseline = titleBaseline 
        self.titleColor = titleColor 
        self.titleFont = titleFont 
        self.titleFontSize = titleFontSize 
        self.titleFontWeight = titleFontWeight 
        self.titleLimit = titleLimit 
        self.titleMaxLength = titleMaxLength 
        self.titlePadding = titlePadding 
        self.titleX = titleX 
        self.titleY = titleY 
    }

    public enum CodingKeys : String, CodingKey {
        case bandPosition
        case domain
        case domainColor
        case domainWidth
        case grid
        case gridColor
        case gridDash
        case gridOpacity
        case gridWidth
        case labelAngle
        case labelBound
        case labelColor
        case labelFlush
        case labelFont
        case labelFontSize
        case labelLimit
        case labelOverlap
        case labelPadding
        case labels
        case maxExtent
        case minExtent
        case tickColor
        case tickRound
        case tickSize
        case tickWidth
        case ticks
        case titleAlign
        case titleAngle
        case titleBaseline
        case titleColor
        case titleFont
        case titleFontSize
        case titleFontWeight
        case titleLimit
        case titleMaxLength
        case titlePadding
        case titleX
        case titleY
    }

    public typealias GridDashItem = Double

    public typealias LabelBound = OneOf2<Bool, Double>

    public typealias LabelFlush = OneOf2<Bool, Double>

    /// The strategy to use for resolving overlap of axis labels. If `false` (the default), no overlap reduction is attempted. If set to `true` or `"parity"`, a strategy of removing every other label is used (this works well for standard linear axes). If set to `"greedy"`, a linear scan of the labels is performed, removing any labels that overlaps with the last visible label (this often works better for log-scaled axes).
    /// __Default value:__ `true` for non-nominal fields with non-log scales; `"greedy"` for log scales; otherwise `false`.
    public typealias LabelOverlapChoice = LabelOverlapTypes.Choice
    public enum LabelOverlapTypes {

        public typealias Choice = OneOf3<Bool, Type2, Type3>

        public enum Type2 : String, Equatable, Codable {
            case parity
        }

        public enum Type3 : String, Equatable, Codable {
            case greedy
        }
    }
}

public typealias DictInlineDataset = Dictionary<String, DictInlineDatasetValue>
public typealias DictInlineDatasetValue = InlineDataset

public struct ConditionalSelectionFieldDef : Equatable, Codable {
    /// A [selection name](https://vega.github.io/vega-lite/docs/selection.html), or a series of [composed selections](https://vega.github.io/vega-lite/docs/selection.html#compose).
    public var selection: SelectionOperand
    /// The encoded field's type of measurement (`"quantitative"`, `"temporal"`, `"ordinal"`, or `"nominal"`).
    /// It can also be a `"geojson"` type for encoding ['geoshape'](https://vega.github.io/vega-lite/docs/geoshape.html).
    public var type: `Type`
    /// Aggregation function for the field
    /// (e.g., `mean`, `sum`, `median`, `min`, `max`, `count`).
    /// __Default value:__ `undefined` (None)
    public var aggregate: Aggregate?
    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public var bin: BinChoice?
    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public var field: FieldChoice?
    /// Time unit (e.g., `year`, `yearmonth`, `month`, `hours`) for a temporal field.
    /// or [a temporal field that gets casted as ordinal](https://vega.github.io/vega-lite/docs/type.html#cast).
    /// __Default value:__ `undefined` (None)
    public var timeUnit: TimeUnit?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?

    public init(selection: SelectionOperand, type: `Type`, aggregate: Aggregate? = .none, bin: BinChoice? = .none, field: FieldChoice? = .none, timeUnit: TimeUnit? = .none, title: Title? = .none) {
        self.selection = selection 
        self.type = type 
        self.aggregate = aggregate 
        self.bin = bin 
        self.field = field 
        self.timeUnit = timeUnit 
        self.title = title 
    }

    public enum CodingKeys : String, CodingKey {
        case selection
        case type
        case aggregate
        case bin
        case field
        case timeUnit
        case title
    }

    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public typealias BinChoice = OneOf2<Bool, BinParams>

    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public typealias FieldChoice = OneOf2<String, RepeatRef>

    public typealias Title = OneOf2<String, ExplicitNull>
}

public struct IntervalSelection : Equatable, Codable {
    public var type: `Type`
    /// Establishes a two-way binding between the interval selection and the scales
    /// used within the same view. This allows a user to interactively pan and
    /// zoom the view.
    public var bind: Bind?
    /// By default, all data values are considered to lie within an empty selection.
    /// When set to `none`, empty selections contain no data values.
    public var empty: Empty?
    /// An array of encoding channels. The corresponding data field values
    /// must match for a data tuple to fall within the selection.
    public var encodings: [SingleDefChannel]?
    /// An array of field names whose values must match for a data tuple to
    /// fall within the selection.
    public var fields: [FieldsItem]?
    /// An interval selection also adds a rectangle mark to depict the
    /// extents of the interval. The `mark` property can be used to customize the
    /// appearance of the mark.
    public var mark: BrushConfig?
    /// A [Vega event stream](https://vega.github.io/vega/docs/event-streams/) (object or selector) that triggers the selection.
    /// For interval selections, the event stream must specify a [start and end](https://vega.github.io/vega/docs/event-streams/#between-filters).
    public var on: VgEventStream?
    /// With layered and multi-view displays, a strategy that determines how
    /// selections' data queries are resolved when applied in a filter transform,
    /// conditional encoding rule, or scale domain.
    public var resolve: SelectionResolution?
    /// When truthy, allows a user to interactively move an interval selection
    /// back-and-forth. Can be `true`, `false` (to disable panning), or a
    /// [Vega event stream definition](https://vega.github.io/vega/docs/event-streams/)
    /// which must include a start and end event to trigger continuous panning.
    /// __Default value:__ `true`, which corresponds to
    /// `[mousedown, window:mouseup] > window:mousemove!` which corresponds to
    /// clicks and dragging within an interval selection to reposition it.
    public var translate: Translate?
    /// When truthy, allows a user to interactively resize an interval selection.
    /// Can be `true`, `false` (to disable zooming), or a [Vega event stream
    /// definition](https://vega.github.io/vega/docs/event-streams/). Currently,
    /// only `wheel` events are supported.
    /// __Default value:__ `true`, which corresponds to `wheel!`.
    public var zoom: Zoom?

    public init(type: `Type` = .interval, bind: Bind? = .none, empty: Empty? = .none, encodings: [SingleDefChannel]? = .none, fields: [FieldsItem]? = .none, mark: BrushConfig? = .none, on: VgEventStream? = .none, resolve: SelectionResolution? = .none, translate: Translate? = .none, zoom: Zoom? = .none) {
        self.type = type 
        self.bind = bind 
        self.empty = empty 
        self.encodings = encodings 
        self.fields = fields 
        self.mark = mark 
        self.on = on 
        self.resolve = resolve 
        self.translate = translate 
        self.zoom = zoom 
    }

    public enum CodingKeys : String, CodingKey {
        case type
        case bind
        case empty
        case encodings
        case fields
        case mark
        case on
        case resolve
        case translate
        case zoom
    }

    public enum `Type` : String, Equatable, Codable {
        case interval
    }

    /// Establishes a two-way binding between the interval selection and the scales
    /// used within the same view. This allows a user to interactively pan and
    /// zoom the view.
    public enum Bind : String, Equatable, Codable {
        case scales
    }

    /// By default, all data values are considered to lie within an empty selection.
    /// When set to `none`, empty selections contain no data values.
    public enum Empty : String, Equatable, Codable {
        case all
        case none
    }

    public typealias FieldsItem = String

    public typealias Translate = OneOf2<String, Bool>

    public typealias Zoom = OneOf2<String, Bool>
}

public struct VgMarkConfig : Equatable, Codable {
    /// The horizontal alignment of the text. One of `"left"`, `"right"`, `"center"`.
    public var align: HorizontalAlign?
    /// The rotation angle of the text, in degrees.
    public var angle: Double?
    /// The vertical alignment of the text. One of `"top"`, `"middle"`, `"bottom"`.
    /// __Default value:__ `"middle"`
    public var baseline: VerticalAlign?
    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public var cursor: Cursor?
    /// The horizontal offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dx: Double?
    /// The vertical offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dy: Double?
    /// Default Fill Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var fill: String?
    /// The fill opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var fillOpacity: Double?
    /// The typeface to set the text in (e.g., `"Helvetica Neue"`).
    public var font: String?
    /// The font size, in pixels.
    public var fontSize: Double?
    /// The font style (e.g., `"italic"`).
    public var fontStyle: FontStyle?
    /// The font weight.
    /// This can be either a string (e.g `"bold"`, `"normal"`) or a number (`100`, `200`, `300`, ..., `900` where `"normal"` = `400` and `"bold"` = `700`).
    public var fontWeight: FontWeight?
    /// A URL to load upon mouse click. If defined, the mark acts as a hyperlink.
    public var href: String?
    /// The line interpolation method to use for line and area marks. One of the following:
    /// - `"linear"`: piecewise linear segments, as in a polyline.
    /// - `"linear-closed"`: close the linear segments to form a polygon.
    /// - `"step"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"step-before"`: alternate between vertical and horizontal segments, as in a step function.
    /// - `"step-after"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"basis"`: a B-spline, with control point duplication on the ends.
    /// - `"basis-open"`: an open B-spline; may not intersect the start or end.
    /// - `"basis-closed"`: a closed B-spline, as in a loop.
    /// - `"cardinal"`: a Cardinal spline, with control point duplication on the ends.
    /// - `"cardinal-open"`: an open Cardinal spline; may not intersect the start or end, but will intersect other control points.
    /// - `"cardinal-closed"`: a closed Cardinal spline, as in a loop.
    /// - `"bundle"`: equivalent to basis, except the tension parameter is used to straighten the spline.
    /// - `"monotone"`: cubic interpolation that preserves monotonicity in y.
    public var interpolate: Interpolate?
    /// The maximum length of the text mark in pixels (default 0, indicating no limit). The text value will be automatically truncated if the rendered size exceeds the limit.
    public var limit: Double?
    /// The overall opacity (value between [0,1]).
    /// __Default value:__ `0.7` for non-aggregate plots with `point`, `tick`, `circle`, or `square` marks or layered `bar` charts and `1` otherwise.
    public var opacity: Double?
    /// The orientation of a non-stacked bar, tick, area, and line charts.
    /// The value is either horizontal (default) or vertical.
    /// - For bar, rule and tick, this determines whether the size of the bar and tick
    /// should be applied to x or y dimension.
    /// - For area, this property determines the orient property of the Vega output.
    /// - For line and trail marks, this property determines the sort order of the points in the line
    /// if `config.sortLineBy` is not specified.
    /// For stacked charts, this is always determined by the orientation of the stack;
    /// therefore explicitly specified value will be ignored.
    public var orient: Orient?
    /// Polar coordinate radial offset, in pixels, of the text label from the origin determined by the `x` and `y` properties.
    public var radius: Double?
    /// The default symbol shape to use. One of: `"circle"` (default), `"square"`, `"cross"`, `"diamond"`, `"triangle-up"`, or `"triangle-down"`, or a custom SVG path.
    /// __Default value:__ `"circle"`
    public var shape: String?
    /// The pixel area each the point/circle/square.
    /// For example: in the case of circles, the radius is determined in part by the square root of the size value.
    /// __Default value:__ `30`
    public var size: Double?
    /// Default Stroke Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var stroke: String?
    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public var strokeCap: StrokeCap?
    /// An array of alternating stroke, space lengths for creating dashed or dotted lines.
    public var strokeDash: [StrokeDashItem]?
    /// The offset (in pixels) into which to begin drawing with the stroke dash array.
    public var strokeDashOffset: Double?
    /// The stroke opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var strokeOpacity: Double?
    /// The stroke width, in pixels.
    public var strokeWidth: Double?
    /// Depending on the interpolation type, sets the tension parameter (for line and area marks).
    public var tension: Double?
    /// Placeholder text if the `text` channel is not specified
    public var text: String?
    /// Polar coordinate angle, in radians, of the text label from the origin determined by the `x` and `y` properties. Values for `theta` follow the same convention of `arc` mark `startAngle` and `endAngle` properties: angles are measured in radians, with `0` indicating "north".
    public var theta: Double?

    public init(align: HorizontalAlign? = .none, angle: Double? = .none, baseline: VerticalAlign? = .none, cursor: Cursor? = .none, dx: Double? = .none, dy: Double? = .none, fill: String? = .none, fillOpacity: Double? = .none, font: String? = .none, fontSize: Double? = .none, fontStyle: FontStyle? = .none, fontWeight: FontWeight? = .none, href: String? = .none, interpolate: Interpolate? = .none, limit: Double? = .none, opacity: Double? = .none, orient: Orient? = .none, radius: Double? = .none, shape: String? = .none, size: Double? = .none, stroke: String? = .none, strokeCap: StrokeCap? = .none, strokeDash: [StrokeDashItem]? = .none, strokeDashOffset: Double? = .none, strokeOpacity: Double? = .none, strokeWidth: Double? = .none, tension: Double? = .none, text: String? = .none, theta: Double? = .none) {
        self.align = align 
        self.angle = angle 
        self.baseline = baseline 
        self.cursor = cursor 
        self.dx = dx 
        self.dy = dy 
        self.fill = fill 
        self.fillOpacity = fillOpacity 
        self.font = font 
        self.fontSize = fontSize 
        self.fontStyle = fontStyle 
        self.fontWeight = fontWeight 
        self.href = href 
        self.interpolate = interpolate 
        self.limit = limit 
        self.opacity = opacity 
        self.orient = orient 
        self.radius = radius 
        self.shape = shape 
        self.size = size 
        self.stroke = stroke 
        self.strokeCap = strokeCap 
        self.strokeDash = strokeDash 
        self.strokeDashOffset = strokeDashOffset 
        self.strokeOpacity = strokeOpacity 
        self.strokeWidth = strokeWidth 
        self.tension = tension 
        self.text = text 
        self.theta = theta 
    }

    public enum CodingKeys : String, CodingKey {
        case align
        case angle
        case baseline
        case cursor
        case dx
        case dy
        case fill
        case fillOpacity
        case font
        case fontSize
        case fontStyle
        case fontWeight
        case href
        case interpolate
        case limit
        case opacity
        case orient
        case radius
        case shape
        case size
        case stroke
        case strokeCap
        case strokeDash
        case strokeDashOffset
        case strokeOpacity
        case strokeWidth
        case tension
        case text
        case theta
    }

    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public enum Cursor : String, Equatable, Codable {
        case auto
        case `default` = "default"
        case none
        case contextMenu = "context-menu"
        case help
        case pointer
        case progress
        case wait
        case cell
        case crosshair
        case text
        case verticalText = "vertical-text"
        case alias
        case copy
        case move
        case noDrop = "no-drop"
        case notAllowed = "not-allowed"
        case eResize = "e-resize"
        case nResize = "n-resize"
        case neResize = "ne-resize"
        case nwResize = "nw-resize"
        case sResize = "s-resize"
        case seResize = "se-resize"
        case swResize = "sw-resize"
        case wResize = "w-resize"
        case ewResize = "ew-resize"
        case nsResize = "ns-resize"
        case neswResize = "nesw-resize"
        case nwseResize = "nwse-resize"
        case colResize = "col-resize"
        case rowResize = "row-resize"
        case allScroll = "all-scroll"
        case zoomIn = "zoom-in"
        case zoomOut = "zoom-out"
        case grab
        case grabbing
    }

    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public enum StrokeCap : String, Equatable, Codable {
        case butt
        case round
        case square
    }

    public typealias StrokeDashItem = Double
}

public struct FacetSpec : Equatable, Codable {
    /// An object that describes mappings between `row` and `column` channels and their field definitions.
    public var facet: FacetMapping
    /// A specification of the view that gets faceted.
    public var spec: SpecChoice
    /// An object describing the data source
    public var data: Data?
    /// Description of this mark for commenting purpose.
    public var description: String?
    /// Name of the visualization for later reference.
    public var name: String?
    /// Scale, axis, and legend resolutions for facets.
    public var resolve: Resolve?
    /// Title for the plot.
    public var title: TitleChoice?
    /// An array of data transformations such as filter and new field calculation.
    public var transform: [Transform]?

    public init(facet: FacetMapping, spec: SpecChoice, data: Data? = .none, description: String? = .none, name: String? = .none, resolve: Resolve? = .none, title: TitleChoice? = .none, transform: [Transform]? = .none) {
        self.facet = facet 
        self.spec = spec 
        self.data = data 
        self.description = description 
        self.name = name 
        self.resolve = resolve 
        self.title = title 
        self.transform = transform 
    }

    public enum CodingKeys : String, CodingKey {
        case facet
        case spec
        case data
        case description
        case name
        case resolve
        case title
        case transform
    }

    /// A specification of the view that gets faceted.
    public typealias SpecChoice = OneOf2<LayerSpec, CompositeUnitSpec>

    /// Title for the plot.
    public typealias TitleChoice = OneOf2<String, TitleParams>
}

public struct CalculateTransform : Equatable, Codable {
    /// A [expression](https://vega.github.io/vega-lite/docs/types.html#expression) string. Use the variable `datum` to refer to the current data object.
    public var calculate: String
    /// The field for storing the computed formula value.
    public var `as`: String

    public init(calculate: String, `as`: String) {
        self.calculate = calculate 
        self.`as` = `as` 
    }

    public enum CodingKeys : String, CodingKey {
        case calculate
        case `as` = "as"
    }
}

public struct SelectionPredicate : Equatable, Codable {
    /// Filter using a selection name.
    public var selection: SelectionOperand

    public init(selection: SelectionOperand) {
        self.selection = selection 
    }

    public enum CodingKeys : String, CodingKey {
        case selection
    }
}

public struct VgSelectBinding : Equatable, Codable {
    public var input: Input
    public var options: [OptionsItem]
    public var element: String?

    public init(input: Input = .select, options: [OptionsItem] = [], element: String? = .none) {
        self.input = input 
        self.options = options 
        self.element = element 
    }

    public enum CodingKeys : String, CodingKey {
        case input
        case options
        case element
    }

    public enum Input : String, Equatable, Codable {
        case select
    }

    public typealias OptionsItem = String
}

public typealias VgEventStream = Dictionary<String, Bric>

public struct VgRadioBinding : Equatable, Codable {
    public var input: Input
    public var options: [OptionsItem]
    public var element: String?

    public init(input: Input = .radio, options: [OptionsItem] = [], element: String? = .none) {
        self.input = input 
        self.options = options 
        self.element = element 
    }

    public enum CodingKeys : String, CodingKey {
        case input
        case options
        case element
    }

    public enum Input : String, Equatable, Codable {
        case radio
    }

    public typealias OptionsItem = String
}

public struct BrushConfig : Equatable, Codable {
    /// The fill color of the interval mark.
    /// __Default value:__ `#333333`
    public var fill: String?
    /// The fill opacity of the interval mark (a value between 0 and 1).
    /// __Default value:__ `0.125`
    public var fillOpacity: Double?
    /// The stroke color of the interval mark.
    /// __Default value:__ `#ffffff`
    public var stroke: String?
    /// An array of alternating stroke and space lengths,
    /// for creating dashed or dotted lines.
    public var strokeDash: [StrokeDashItem]?
    /// The offset (in pixels) with which to begin drawing the stroke dash array.
    public var strokeDashOffset: Double?
    /// The stroke opacity of the interval mark (a value between 0 and 1).
    public var strokeOpacity: Double?
    /// The stroke width of the interval mark.
    public var strokeWidth: Double?

    public init(fill: String? = .none, fillOpacity: Double? = .none, stroke: String? = .none, strokeDash: [StrokeDashItem]? = .none, strokeDashOffset: Double? = .none, strokeOpacity: Double? = .none, strokeWidth: Double? = .none) {
        self.fill = fill 
        self.fillOpacity = fillOpacity 
        self.stroke = stroke 
        self.strokeDash = strokeDash 
        self.strokeDashOffset = strokeDashOffset 
        self.strokeOpacity = strokeOpacity 
        self.strokeWidth = strokeWidth 
    }

    public enum CodingKeys : String, CodingKey {
        case fill
        case fillOpacity
        case stroke
        case strokeDash
        case strokeDashOffset
        case strokeOpacity
        case strokeWidth
    }

    public typealias StrokeDashItem = Double
}

public struct TimeUnitTransform : Equatable, Codable {
    /// The timeUnit.
    public var timeUnit: TimeUnit
    /// The data field to apply time unit.
    public var field: String
    /// The output field to write the timeUnit value.
    public var `as`: String

    public init(timeUnit: TimeUnit, field: String, `as`: String) {
        self.timeUnit = timeUnit 
        self.field = field 
        self.`as` = `as` 
    }

    public enum CodingKeys : String, CodingKey {
        case timeUnit
        case field
        case `as` = "as"
    }
}

public enum NiceTime : String, Equatable, Codable {
    case second
    case minute
    case hour
    case day
    case week
    case month
    case year
}

public struct SelectionNot : Equatable, Codable {
    public var not: SelectionOperand

    public init(not: SelectionOperand) {
        self.not = not 
    }

    public enum CodingKeys : String, CodingKey {
        case not
    }
}

public typealias StyleConfigIndex = Dictionary<String, StyleConfigIndexValue>
public typealias StyleConfigIndexValue = VgMarkConfig

public struct TickConfig : Equatable, Codable {
    /// The horizontal alignment of the text. One of `"left"`, `"right"`, `"center"`.
    public var align: HorizontalAlign?
    /// The rotation angle of the text, in degrees.
    public var angle: Double?
    /// The width of the ticks.
    /// __Default value:__  2/3 of rangeStep.
    public var bandSize: Double?
    /// The vertical alignment of the text. One of `"top"`, `"middle"`, `"bottom"`.
    /// __Default value:__ `"middle"`
    public var baseline: VerticalAlign?
    /// Default color.  Note that `fill` and `stroke` have higher precedence than `color` and will override `color`.
    /// __Default value:__ <span style="color: #4682b4;">&#9632;</span> `"#4682b4"`
    /// __Note:__ This property cannot be used in a [style config](https://vega.github.io/vega-lite/docs/mark.html#style-config).
    public var color: String?
    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public var cursor: Cursor?
    /// The horizontal offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dx: Double?
    /// The vertical offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dy: Double?
    /// Default Fill Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var fill: String?
    /// The fill opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var fillOpacity: Double?
    /// Whether the mark's color should be used as fill color instead of stroke color.
    /// __Default value:__ `true` for all marks except `point` and `false` for `point`.
    /// __Applicable for:__ `bar`, `point`, `circle`, `square`, and `area` marks.
    /// __Note:__ This property cannot be used in a [style config](https://vega.github.io/vega-lite/docs/mark.html#style-config).
    public var filled: Bool?
    /// The typeface to set the text in (e.g., `"Helvetica Neue"`).
    public var font: String?
    /// The font size, in pixels.
    public var fontSize: Double?
    /// The font style (e.g., `"italic"`).
    public var fontStyle: FontStyle?
    /// The font weight.
    /// This can be either a string (e.g `"bold"`, `"normal"`) or a number (`100`, `200`, `300`, ..., `900` where `"normal"` = `400` and `"bold"` = `700`).
    public var fontWeight: FontWeight?
    /// A URL to load upon mouse click. If defined, the mark acts as a hyperlink.
    public var href: String?
    /// The line interpolation method to use for line and area marks. One of the following:
    /// - `"linear"`: piecewise linear segments, as in a polyline.
    /// - `"linear-closed"`: close the linear segments to form a polygon.
    /// - `"step"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"step-before"`: alternate between vertical and horizontal segments, as in a step function.
    /// - `"step-after"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"basis"`: a B-spline, with control point duplication on the ends.
    /// - `"basis-open"`: an open B-spline; may not intersect the start or end.
    /// - `"basis-closed"`: a closed B-spline, as in a loop.
    /// - `"cardinal"`: a Cardinal spline, with control point duplication on the ends.
    /// - `"cardinal-open"`: an open Cardinal spline; may not intersect the start or end, but will intersect other control points.
    /// - `"cardinal-closed"`: a closed Cardinal spline, as in a loop.
    /// - `"bundle"`: equivalent to basis, except the tension parameter is used to straighten the spline.
    /// - `"monotone"`: cubic interpolation that preserves monotonicity in y.
    public var interpolate: Interpolate?
    /// The maximum length of the text mark in pixels (default 0, indicating no limit). The text value will be automatically truncated if the rendered size exceeds the limit.
    public var limit: Double?
    /// The overall opacity (value between [0,1]).
    /// __Default value:__ `0.7` for non-aggregate plots with `point`, `tick`, `circle`, or `square` marks or layered `bar` charts and `1` otherwise.
    public var opacity: Double?
    /// The orientation of a non-stacked bar, tick, area, and line charts.
    /// The value is either horizontal (default) or vertical.
    /// - For bar, rule and tick, this determines whether the size of the bar and tick
    /// should be applied to x or y dimension.
    /// - For area, this property determines the orient property of the Vega output.
    /// - For line and trail marks, this property determines the sort order of the points in the line
    /// if `config.sortLineBy` is not specified.
    /// For stacked charts, this is always determined by the orientation of the stack;
    /// therefore explicitly specified value will be ignored.
    public var orient: Orient?
    /// Polar coordinate radial offset, in pixels, of the text label from the origin determined by the `x` and `y` properties.
    public var radius: Double?
    /// The default symbol shape to use. One of: `"circle"` (default), `"square"`, `"cross"`, `"diamond"`, `"triangle-up"`, or `"triangle-down"`, or a custom SVG path.
    /// __Default value:__ `"circle"`
    public var shape: String?
    /// The pixel area each the point/circle/square.
    /// For example: in the case of circles, the radius is determined in part by the square root of the size value.
    /// __Default value:__ `30`
    public var size: Double?
    /// Default Stroke Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var stroke: String?
    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public var strokeCap: StrokeCap?
    /// An array of alternating stroke, space lengths for creating dashed or dotted lines.
    public var strokeDash: [StrokeDashItem]?
    /// The offset (in pixels) into which to begin drawing with the stroke dash array.
    public var strokeDashOffset: Double?
    /// The stroke opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var strokeOpacity: Double?
    /// The stroke width, in pixels.
    public var strokeWidth: Double?
    /// Depending on the interpolation type, sets the tension parameter (for line and area marks).
    public var tension: Double?
    /// Placeholder text if the `text` channel is not specified
    public var text: String?
    /// Polar coordinate angle, in radians, of the text label from the origin determined by the `x` and `y` properties. Values for `theta` follow the same convention of `arc` mark `startAngle` and `endAngle` properties: angles are measured in radians, with `0` indicating "north".
    public var theta: Double?
    /// Thickness of the tick mark.
    /// __Default value:__  `1`
    public var thickness: Double?

    public init(align: HorizontalAlign? = .none, angle: Double? = .none, bandSize: Double? = .none, baseline: VerticalAlign? = .none, color: String? = .none, cursor: Cursor? = .none, dx: Double? = .none, dy: Double? = .none, fill: String? = .none, fillOpacity: Double? = .none, filled: Bool? = .none, font: String? = .none, fontSize: Double? = .none, fontStyle: FontStyle? = .none, fontWeight: FontWeight? = .none, href: String? = .none, interpolate: Interpolate? = .none, limit: Double? = .none, opacity: Double? = .none, orient: Orient? = .none, radius: Double? = .none, shape: String? = .none, size: Double? = .none, stroke: String? = .none, strokeCap: StrokeCap? = .none, strokeDash: [StrokeDashItem]? = .none, strokeDashOffset: Double? = .none, strokeOpacity: Double? = .none, strokeWidth: Double? = .none, tension: Double? = .none, text: String? = .none, theta: Double? = .none, thickness: Double? = .none) {
        self.align = align 
        self.angle = angle 
        self.bandSize = bandSize 
        self.baseline = baseline 
        self.color = color 
        self.cursor = cursor 
        self.dx = dx 
        self.dy = dy 
        self.fill = fill 
        self.fillOpacity = fillOpacity 
        self.filled = filled 
        self.font = font 
        self.fontSize = fontSize 
        self.fontStyle = fontStyle 
        self.fontWeight = fontWeight 
        self.href = href 
        self.interpolate = interpolate 
        self.limit = limit 
        self.opacity = opacity 
        self.orient = orient 
        self.radius = radius 
        self.shape = shape 
        self.size = size 
        self.stroke = stroke 
        self.strokeCap = strokeCap 
        self.strokeDash = strokeDash 
        self.strokeDashOffset = strokeDashOffset 
        self.strokeOpacity = strokeOpacity 
        self.strokeWidth = strokeWidth 
        self.tension = tension 
        self.text = text 
        self.theta = theta 
        self.thickness = thickness 
    }

    public enum CodingKeys : String, CodingKey {
        case align
        case angle
        case bandSize
        case baseline
        case color
        case cursor
        case dx
        case dy
        case fill
        case fillOpacity
        case filled
        case font
        case fontSize
        case fontStyle
        case fontWeight
        case href
        case interpolate
        case limit
        case opacity
        case orient
        case radius
        case shape
        case size
        case stroke
        case strokeCap
        case strokeDash
        case strokeDashOffset
        case strokeOpacity
        case strokeWidth
        case tension
        case text
        case theta
        case thickness
    }

    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public enum Cursor : String, Equatable, Codable {
        case auto
        case `default` = "default"
        case none
        case contextMenu = "context-menu"
        case help
        case pointer
        case progress
        case wait
        case cell
        case crosshair
        case text
        case verticalText = "vertical-text"
        case alias
        case copy
        case move
        case noDrop = "no-drop"
        case notAllowed = "not-allowed"
        case eResize = "e-resize"
        case nResize = "n-resize"
        case neResize = "ne-resize"
        case nwResize = "nw-resize"
        case sResize = "s-resize"
        case seResize = "se-resize"
        case swResize = "sw-resize"
        case wResize = "w-resize"
        case ewResize = "ew-resize"
        case nsResize = "ns-resize"
        case neswResize = "nesw-resize"
        case nwseResize = "nwse-resize"
        case colResize = "col-resize"
        case rowResize = "row-resize"
        case allScroll = "all-scroll"
        case zoomIn = "zoom-in"
        case zoomOut = "zoom-out"
        case grab
        case grabbing
    }

    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public enum StrokeCap : String, Equatable, Codable {
        case butt
        case round
        case square
    }

    public typealias StrokeDashItem = Double
}

public enum ScaleType : String, Equatable, Codable {
    case linear
    case binLinear = "bin-linear"
    case log
    case pow
    case sqrt
    case time
    case utc
    case sequential
    case ordinal
    case binOrdinal = "bin-ordinal"
    case point
    case band
}

public struct SchemeParams : Equatable, Codable {
    /// A color scheme name for sequential/ordinal scales (e.g., `"category10"` or `"viridis"`).
    /// For the full list of supported schemes, please refer to the [Vega Scheme](https://vega.github.io/vega/docs/schemes/#reference) reference.
    public var name: String
    /// For sequential and diverging schemes only, determines the extent of the color range to use. For example `[0.2, 1]` will rescale the color scheme such that color values in the range _[0, 0.2)_ are excluded from the scheme.
    public var extent: [ExtentItem]?

    public init(name: String, extent: [ExtentItem]? = .none) {
        self.name = name 
        self.extent = extent 
    }

    public enum CodingKeys : String, CodingKey {
        case name
        case extent
    }

    public typealias ExtentItem = Double
}

public struct LogicalAndPredicate : Equatable, Codable {
    public var and: [LogicalOperandPredicate]

    public init(and: [LogicalOperandPredicate] = []) {
        self.and = and 
    }

    public enum CodingKeys : String, CodingKey {
        case and
    }
}

public typealias Padding = PaddingTypes.Choice
public enum PaddingTypes {

    public typealias Choice = OneOf2<Double, BottomLeftRightTopType>

    public struct BottomLeftRightTopType : Equatable, Codable {
        public var bottom: Double?
        public var left: Double?
        public var right: Double?
        public var top: Double?

        public init(bottom: Double? = .none, left: Double? = .none, right: Double? = .none, top: Double? = .none) {
            self.bottom = bottom 
            self.left = left 
            self.right = right 
            self.top = top 
        }

        public enum CodingKeys : String, CodingKey {
            case bottom
            case left
            case right
            case top
        }
    }
}

public typealias DataFormat = OneOf4<CsvDataFormat, DsvDataFormat, JsonDataFormat, TopoDataFormat>

public struct AxisConfig : Equatable, Codable {
    /// An interpolation fraction indicating where, for `band` scales, axis ticks should be positioned. A value of `0` places ticks at the left edge of their bands. A value of `0.5` places ticks in the middle of their bands.
    public var bandPosition: Double?
    /// A boolean flag indicating if the domain (the axis baseline) should be included as part of the axis.
    /// __Default value:__ `true`
    public var domain: Bool?
    /// Color of axis domain line.
    /// __Default value:__  (none, using Vega default).
    public var domainColor: String?
    /// Stroke width of axis domain line
    /// __Default value:__  (none, using Vega default).
    public var domainWidth: Double?
    /// A boolean flag indicating if grid lines should be included as part of the axis
    /// __Default value:__ `true` for [continuous scales](https://vega.github.io/vega-lite/docs/scale.html#continuous) that are not binned; otherwise, `false`.
    public var grid: Bool?
    /// Color of gridlines.
    public var gridColor: String?
    /// The offset (in pixels) into which to begin drawing with the grid dash array.
    public var gridDash: [GridDashItem]?
    /// The stroke opacity of grid (value between [0,1])
    /// __Default value:__ (`1` by default)
    public var gridOpacity: Double?
    /// The grid width, in pixels.
    public var gridWidth: Double?
    /// The rotation angle of the axis labels.
    /// __Default value:__ `-90` for nominal and ordinal fields; `0` otherwise.
    public var labelAngle: Double?
    /// Indicates if labels should be hidden if they exceed the axis range. If `false `(the default) no bounds overlap analysis is performed. If `true`, labels will be hidden if they exceed the axis range by more than 1 pixel. If this property is a number, it specifies the pixel tolerance: the maximum amount by which a label bounding box may exceed the axis range.
    /// __Default value:__ `false`.
    public var labelBound: LabelBound?
    /// The color of the tick label, can be in hex color code or regular color name.
    public var labelColor: String?
    /// Indicates if the first and last axis labels should be aligned flush with the scale range. Flush alignment for a horizontal axis will left-align the first label and right-align the last label. For vertical axes, bottom and top text baselines are applied instead. If this property is a number, it also indicates the number of pixels by which to offset the first and last labels; for example, a value of 2 will flush-align the first and last labels and also push them 2 pixels outward from the center of the axis. The additional adjustment can sometimes help the labels better visually group with corresponding axis ticks.
    /// __Default value:__ `true` for axis of a continuous x-scale. Otherwise, `false`.
    public var labelFlush: LabelFlush?
    /// The font of the tick label.
    public var labelFont: String?
    /// The font size of the label, in pixels.
    public var labelFontSize: Double?
    /// Maximum allowed pixel width of axis tick labels.
    public var labelLimit: Double?
    /// The strategy to use for resolving overlap of axis labels. If `false` (the default), no overlap reduction is attempted. If set to `true` or `"parity"`, a strategy of removing every other label is used (this works well for standard linear axes). If set to `"greedy"`, a linear scan of the labels is performed, removing any labels that overlaps with the last visible label (this often works better for log-scaled axes).
    /// __Default value:__ `true` for non-nominal fields with non-log scales; `"greedy"` for log scales; otherwise `false`.
    public var labelOverlap: LabelOverlapChoice?
    /// The padding, in pixels, between axis and text labels.
    public var labelPadding: Double?
    /// A boolean flag indicating if labels should be included as part of the axis.
    /// __Default value:__  `true`.
    public var labels: Bool?
    /// The maximum extent in pixels that axis ticks and labels should use. This determines a maximum offset value for axis titles.
    /// __Default value:__ `undefined`.
    public var maxExtent: Double?
    /// The minimum extent in pixels that axis ticks and labels should use. This determines a minimum offset value for axis titles.
    /// __Default value:__ `30` for y-axis; `undefined` for x-axis.
    public var minExtent: Double?
    /// Whether month names and weekday names should be abbreviated.
    /// __Default value:__  `false`
    public var shortTimeLabels: Bool?
    /// The color of the axis's tick.
    public var tickColor: String?
    /// Boolean flag indicating if pixel position values should be rounded to the nearest integer.
    public var tickRound: Bool?
    /// The size in pixels of axis ticks.
    public var tickSize: Double?
    /// The width, in pixels, of ticks.
    public var tickWidth: Double?
    /// Boolean value that determines whether the axis should include ticks.
    public var ticks: Bool?
    /// Horizontal text alignment of axis titles.
    public var titleAlign: String?
    /// Angle in degrees of axis titles.
    public var titleAngle: Double?
    /// Vertical text baseline for axis titles.
    public var titleBaseline: String?
    /// Color of the title, can be in hex color code or regular color name.
    public var titleColor: String?
    /// Font of the title. (e.g., `"Helvetica Neue"`).
    public var titleFont: String?
    /// Font size of the title.
    public var titleFontSize: Double?
    /// Font weight of the title.
    /// This can be either a string (e.g `"bold"`, `"normal"`) or a number (`100`, `200`, `300`, ..., `900` where `"normal"` = `400` and `"bold"` = `700`).
    public var titleFontWeight: FontWeight?
    /// Maximum allowed pixel width of axis titles.
    public var titleLimit: Double?
    /// Max length for axis title if the title is automatically generated from the field's description.
    public var titleMaxLength: Double?
    /// The padding, in pixels, between title and axis.
    public var titlePadding: Double?
    /// X-coordinate of the axis title relative to the axis group.
    public var titleX: Double?
    /// Y-coordinate of the axis title relative to the axis group.
    public var titleY: Double?

    public init(bandPosition: Double? = .none, domain: Bool? = .none, domainColor: String? = .none, domainWidth: Double? = .none, grid: Bool? = .none, gridColor: String? = .none, gridDash: [GridDashItem]? = .none, gridOpacity: Double? = .none, gridWidth: Double? = .none, labelAngle: Double? = .none, labelBound: LabelBound? = .none, labelColor: String? = .none, labelFlush: LabelFlush? = .none, labelFont: String? = .none, labelFontSize: Double? = .none, labelLimit: Double? = .none, labelOverlap: LabelOverlapChoice? = .none, labelPadding: Double? = .none, labels: Bool? = .none, maxExtent: Double? = .none, minExtent: Double? = .none, shortTimeLabels: Bool? = .none, tickColor: String? = .none, tickRound: Bool? = .none, tickSize: Double? = .none, tickWidth: Double? = .none, ticks: Bool? = .none, titleAlign: String? = .none, titleAngle: Double? = .none, titleBaseline: String? = .none, titleColor: String? = .none, titleFont: String? = .none, titleFontSize: Double? = .none, titleFontWeight: FontWeight? = .none, titleLimit: Double? = .none, titleMaxLength: Double? = .none, titlePadding: Double? = .none, titleX: Double? = .none, titleY: Double? = .none) {
        self.bandPosition = bandPosition 
        self.domain = domain 
        self.domainColor = domainColor 
        self.domainWidth = domainWidth 
        self.grid = grid 
        self.gridColor = gridColor 
        self.gridDash = gridDash 
        self.gridOpacity = gridOpacity 
        self.gridWidth = gridWidth 
        self.labelAngle = labelAngle 
        self.labelBound = labelBound 
        self.labelColor = labelColor 
        self.labelFlush = labelFlush 
        self.labelFont = labelFont 
        self.labelFontSize = labelFontSize 
        self.labelLimit = labelLimit 
        self.labelOverlap = labelOverlap 
        self.labelPadding = labelPadding 
        self.labels = labels 
        self.maxExtent = maxExtent 
        self.minExtent = minExtent 
        self.shortTimeLabels = shortTimeLabels 
        self.tickColor = tickColor 
        self.tickRound = tickRound 
        self.tickSize = tickSize 
        self.tickWidth = tickWidth 
        self.ticks = ticks 
        self.titleAlign = titleAlign 
        self.titleAngle = titleAngle 
        self.titleBaseline = titleBaseline 
        self.titleColor = titleColor 
        self.titleFont = titleFont 
        self.titleFontSize = titleFontSize 
        self.titleFontWeight = titleFontWeight 
        self.titleLimit = titleLimit 
        self.titleMaxLength = titleMaxLength 
        self.titlePadding = titlePadding 
        self.titleX = titleX 
        self.titleY = titleY 
    }

    public enum CodingKeys : String, CodingKey {
        case bandPosition
        case domain
        case domainColor
        case domainWidth
        case grid
        case gridColor
        case gridDash
        case gridOpacity
        case gridWidth
        case labelAngle
        case labelBound
        case labelColor
        case labelFlush
        case labelFont
        case labelFontSize
        case labelLimit
        case labelOverlap
        case labelPadding
        case labels
        case maxExtent
        case minExtent
        case shortTimeLabels
        case tickColor
        case tickRound
        case tickSize
        case tickWidth
        case ticks
        case titleAlign
        case titleAngle
        case titleBaseline
        case titleColor
        case titleFont
        case titleFontSize
        case titleFontWeight
        case titleLimit
        case titleMaxLength
        case titlePadding
        case titleX
        case titleY
    }

    public typealias GridDashItem = Double

    public typealias LabelBound = OneOf2<Bool, Double>

    public typealias LabelFlush = OneOf2<Bool, Double>

    /// The strategy to use for resolving overlap of axis labels. If `false` (the default), no overlap reduction is attempted. If set to `true` or `"parity"`, a strategy of removing every other label is used (this works well for standard linear axes). If set to `"greedy"`, a linear scan of the labels is performed, removing any labels that overlaps with the last visible label (this often works better for log-scaled axes).
    /// __Default value:__ `true` for non-nominal fields with non-log scales; `"greedy"` for log scales; otherwise `false`.
    public typealias LabelOverlapChoice = LabelOverlapTypes.Choice
    public enum LabelOverlapTypes {

        public typealias Choice = OneOf3<Bool, Type2, Type3>

        public enum Type2 : String, Equatable, Codable {
            case parity
        }

        public enum Type3 : String, Equatable, Codable {
            case greedy
        }
    }
}

public struct FieldLTPredicate : Equatable, Codable {
    /// Field to be filtered.
    public var field: String
    /// The value that the field should be less than.
    public var lt: LtChoice
    /// Time unit for the field to be filtered.
    public var timeUnit: TimeUnit?

    public init(field: String, lt: LtChoice, timeUnit: TimeUnit? = .none) {
        self.field = field 
        self.lt = lt 
        self.timeUnit = timeUnit 
    }

    public enum CodingKeys : String, CodingKey {
        case field
        case lt
        case timeUnit
    }

    /// The value that the field should be less than.
    public typealias LtChoice = OneOf3<String, Double, DateTime>
}

public struct SelectionConfig : Equatable, Codable {
    /// The default definition for an [`interval`](https://vega.github.io/vega-lite/docs/selection.html#type) selection. All properties and transformations
    /// for an interval selection definition (except `type`) may be specified here.
    /// For instance, setting `interval` to `{"translate": false}` disables the ability to move
    /// interval selections by default.
    public var interval: IntervalSelectionConfig?
    /// The default definition for a [`multi`](https://vega.github.io/vega-lite/docs/selection.html#type) selection. All properties and transformations
    /// for a multi selection definition (except `type`) may be specified here.
    /// For instance, setting `multi` to `{"toggle": "event.altKey"}` adds additional values to
    /// multi selections when clicking with the alt-key pressed by default.
    public var multi: MultiSelectionConfig?
    /// The default definition for a [`single`](https://vega.github.io/vega-lite/docs/selection.html#type) selection. All properties and transformations
    ///   for a single selection definition (except `type`) may be specified here.
    /// For instance, setting `single` to `{"on": "dblclick"}` populates single selections on double-click by default.
    public var single: SingleSelectionConfig?

    public init(interval: IntervalSelectionConfig? = .none, multi: MultiSelectionConfig? = .none, single: SingleSelectionConfig? = .none) {
        self.interval = interval 
        self.multi = multi 
        self.single = single 
    }

    public enum CodingKeys : String, CodingKey {
        case interval
        case multi
        case single
    }
}

public typealias Day = Double

public struct CsvDataFormat : Equatable, Codable {
    /// If set to `"auto"` (the default), perform automatic type inference to determine the desired data types.
    /// If set to `null`, disable type inference based on the spec and only use type inference based on the data.
    /// Alternatively, a parsing directive object can be provided for explicit data types. Each property of the object corresponds to a field name, and the value to the desired data type (one of `"number"`, `"boolean"`, `"date"`, or null (do not parse the field)).
    /// For example, `"parse": {"modified_on": "date"}` parses the `modified_on` field in each input record a Date value.
    /// For `"date"`, we parse data based using Javascript's [`Date.parse()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse).
    /// For Specific date formats can be provided (e.g., `{foo: 'date:"%m%d%Y"'}`), using the [d3-time-format syntax](https://github.com/d3/d3-time-format#locale_format). UTC date format parsing is supported similarly (e.g., `{foo: 'utc:"%m%d%Y"'}`). See more about [UTC time](https://vega.github.io/vega-lite/docs/timeunit.html#utc)
    public var parse: ParseChoice?
    /// Type of input data: `"json"`, `"csv"`, `"tsv"`, `"dsv"`.
    /// The default format type is determined by the extension of the file URL.
    /// If no extension is detected, `"json"` will be used by default.
    public var type: `Type`?

    public init(parse: ParseChoice? = .none, type: `Type`? = .none) {
        self.parse = parse 
        self.type = type 
    }

    public enum CodingKeys : String, CodingKey {
        case parse
        case type
    }

    /// If set to `"auto"` (the default), perform automatic type inference to determine the desired data types.
    /// If set to `null`, disable type inference based on the spec and only use type inference based on the data.
    /// Alternatively, a parsing directive object can be provided for explicit data types. Each property of the object corresponds to a field name, and the value to the desired data type (one of `"number"`, `"boolean"`, `"date"`, or null (do not parse the field)).
    /// For example, `"parse": {"modified_on": "date"}` parses the `modified_on` field in each input record a Date value.
    /// For `"date"`, we parse data based using Javascript's [`Date.parse()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse).
    /// For Specific date formats can be provided (e.g., `{foo: 'date:"%m%d%Y"'}`), using the [d3-time-format syntax](https://github.com/d3/d3-time-format#locale_format). UTC date format parsing is supported similarly (e.g., `{foo: 'utc:"%m%d%Y"'}`). See more about [UTC time](https://vega.github.io/vega-lite/docs/timeunit.html#utc)
    public typealias ParseChoice = ParseTypes.Choice
    public enum ParseTypes {

        public typealias Choice = OneOf3<Type1, Parse, ExplicitNull>

        public enum Type1 : String, Equatable, Codable {
            case auto
        }
    }

    /// Type of input data: `"json"`, `"csv"`, `"tsv"`, `"dsv"`.
    /// The default format type is determined by the extension of the file URL.
    /// If no extension is detected, `"json"` will be used by default.
    public enum `Type` : String, Equatable, Codable {
        case csv
        case tsv
    }
}

public struct MarkConfig : Equatable, Codable {
    /// The horizontal alignment of the text. One of `"left"`, `"right"`, `"center"`.
    public var align: HorizontalAlign?
    /// The rotation angle of the text, in degrees.
    public var angle: Double?
    /// The vertical alignment of the text. One of `"top"`, `"middle"`, `"bottom"`.
    /// __Default value:__ `"middle"`
    public var baseline: VerticalAlign?
    /// Default color.  Note that `fill` and `stroke` have higher precedence than `color` and will override `color`.
    /// __Default value:__ <span style="color: #4682b4;">&#9632;</span> `"#4682b4"`
    /// __Note:__ This property cannot be used in a [style config](https://vega.github.io/vega-lite/docs/mark.html#style-config).
    public var color: String?
    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public var cursor: Cursor?
    /// The horizontal offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dx: Double?
    /// The vertical offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dy: Double?
    /// Default Fill Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var fill: String?
    /// The fill opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var fillOpacity: Double?
    /// Whether the mark's color should be used as fill color instead of stroke color.
    /// __Default value:__ `true` for all marks except `point` and `false` for `point`.
    /// __Applicable for:__ `bar`, `point`, `circle`, `square`, and `area` marks.
    /// __Note:__ This property cannot be used in a [style config](https://vega.github.io/vega-lite/docs/mark.html#style-config).
    public var filled: Bool?
    /// The typeface to set the text in (e.g., `"Helvetica Neue"`).
    public var font: String?
    /// The font size, in pixels.
    public var fontSize: Double?
    /// The font style (e.g., `"italic"`).
    public var fontStyle: FontStyle?
    /// The font weight.
    /// This can be either a string (e.g `"bold"`, `"normal"`) or a number (`100`, `200`, `300`, ..., `900` where `"normal"` = `400` and `"bold"` = `700`).
    public var fontWeight: FontWeight?
    /// A URL to load upon mouse click. If defined, the mark acts as a hyperlink.
    public var href: String?
    /// The line interpolation method to use for line and area marks. One of the following:
    /// - `"linear"`: piecewise linear segments, as in a polyline.
    /// - `"linear-closed"`: close the linear segments to form a polygon.
    /// - `"step"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"step-before"`: alternate between vertical and horizontal segments, as in a step function.
    /// - `"step-after"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"basis"`: a B-spline, with control point duplication on the ends.
    /// - `"basis-open"`: an open B-spline; may not intersect the start or end.
    /// - `"basis-closed"`: a closed B-spline, as in a loop.
    /// - `"cardinal"`: a Cardinal spline, with control point duplication on the ends.
    /// - `"cardinal-open"`: an open Cardinal spline; may not intersect the start or end, but will intersect other control points.
    /// - `"cardinal-closed"`: a closed Cardinal spline, as in a loop.
    /// - `"bundle"`: equivalent to basis, except the tension parameter is used to straighten the spline.
    /// - `"monotone"`: cubic interpolation that preserves monotonicity in y.
    public var interpolate: Interpolate?
    /// The maximum length of the text mark in pixels (default 0, indicating no limit). The text value will be automatically truncated if the rendered size exceeds the limit.
    public var limit: Double?
    /// The overall opacity (value between [0,1]).
    /// __Default value:__ `0.7` for non-aggregate plots with `point`, `tick`, `circle`, or `square` marks or layered `bar` charts and `1` otherwise.
    public var opacity: Double?
    /// The orientation of a non-stacked bar, tick, area, and line charts.
    /// The value is either horizontal (default) or vertical.
    /// - For bar, rule and tick, this determines whether the size of the bar and tick
    /// should be applied to x or y dimension.
    /// - For area, this property determines the orient property of the Vega output.
    /// - For line and trail marks, this property determines the sort order of the points in the line
    /// if `config.sortLineBy` is not specified.
    /// For stacked charts, this is always determined by the orientation of the stack;
    /// therefore explicitly specified value will be ignored.
    public var orient: Orient?
    /// Polar coordinate radial offset, in pixels, of the text label from the origin determined by the `x` and `y` properties.
    public var radius: Double?
    /// The default symbol shape to use. One of: `"circle"` (default), `"square"`, `"cross"`, `"diamond"`, `"triangle-up"`, or `"triangle-down"`, or a custom SVG path.
    /// __Default value:__ `"circle"`
    public var shape: String?
    /// The pixel area each the point/circle/square.
    /// For example: in the case of circles, the radius is determined in part by the square root of the size value.
    /// __Default value:__ `30`
    public var size: Double?
    /// Default Stroke Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var stroke: String?
    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public var strokeCap: StrokeCap?
    /// An array of alternating stroke, space lengths for creating dashed or dotted lines.
    public var strokeDash: [StrokeDashItem]?
    /// The offset (in pixels) into which to begin drawing with the stroke dash array.
    public var strokeDashOffset: Double?
    /// The stroke opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var strokeOpacity: Double?
    /// The stroke width, in pixels.
    public var strokeWidth: Double?
    /// Depending on the interpolation type, sets the tension parameter (for line and area marks).
    public var tension: Double?
    /// Placeholder text if the `text` channel is not specified
    public var text: String?
    /// Polar coordinate angle, in radians, of the text label from the origin determined by the `x` and `y` properties. Values for `theta` follow the same convention of `arc` mark `startAngle` and `endAngle` properties: angles are measured in radians, with `0` indicating "north".
    public var theta: Double?

    public init(align: HorizontalAlign? = .none, angle: Double? = .none, baseline: VerticalAlign? = .none, color: String? = .none, cursor: Cursor? = .none, dx: Double? = .none, dy: Double? = .none, fill: String? = .none, fillOpacity: Double? = .none, filled: Bool? = .none, font: String? = .none, fontSize: Double? = .none, fontStyle: FontStyle? = .none, fontWeight: FontWeight? = .none, href: String? = .none, interpolate: Interpolate? = .none, limit: Double? = .none, opacity: Double? = .none, orient: Orient? = .none, radius: Double? = .none, shape: String? = .none, size: Double? = .none, stroke: String? = .none, strokeCap: StrokeCap? = .none, strokeDash: [StrokeDashItem]? = .none, strokeDashOffset: Double? = .none, strokeOpacity: Double? = .none, strokeWidth: Double? = .none, tension: Double? = .none, text: String? = .none, theta: Double? = .none) {
        self.align = align 
        self.angle = angle 
        self.baseline = baseline 
        self.color = color 
        self.cursor = cursor 
        self.dx = dx 
        self.dy = dy 
        self.fill = fill 
        self.fillOpacity = fillOpacity 
        self.filled = filled 
        self.font = font 
        self.fontSize = fontSize 
        self.fontStyle = fontStyle 
        self.fontWeight = fontWeight 
        self.href = href 
        self.interpolate = interpolate 
        self.limit = limit 
        self.opacity = opacity 
        self.orient = orient 
        self.radius = radius 
        self.shape = shape 
        self.size = size 
        self.stroke = stroke 
        self.strokeCap = strokeCap 
        self.strokeDash = strokeDash 
        self.strokeDashOffset = strokeDashOffset 
        self.strokeOpacity = strokeOpacity 
        self.strokeWidth = strokeWidth 
        self.tension = tension 
        self.text = text 
        self.theta = theta 
    }

    public enum CodingKeys : String, CodingKey {
        case align
        case angle
        case baseline
        case color
        case cursor
        case dx
        case dy
        case fill
        case fillOpacity
        case filled
        case font
        case fontSize
        case fontStyle
        case fontWeight
        case href
        case interpolate
        case limit
        case opacity
        case orient
        case radius
        case shape
        case size
        case stroke
        case strokeCap
        case strokeDash
        case strokeDashOffset
        case strokeOpacity
        case strokeWidth
        case tension
        case text
        case theta
    }

    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public enum Cursor : String, Equatable, Codable {
        case auto
        case `default` = "default"
        case none
        case contextMenu = "context-menu"
        case help
        case pointer
        case progress
        case wait
        case cell
        case crosshair
        case text
        case verticalText = "vertical-text"
        case alias
        case copy
        case move
        case noDrop = "no-drop"
        case notAllowed = "not-allowed"
        case eResize = "e-resize"
        case nResize = "n-resize"
        case neResize = "ne-resize"
        case nwResize = "nw-resize"
        case sResize = "s-resize"
        case seResize = "se-resize"
        case swResize = "sw-resize"
        case wResize = "w-resize"
        case ewResize = "ew-resize"
        case nsResize = "ns-resize"
        case neswResize = "nesw-resize"
        case nwseResize = "nwse-resize"
        case colResize = "col-resize"
        case rowResize = "row-resize"
        case allScroll = "all-scroll"
        case zoomIn = "zoom-in"
        case zoomOut = "zoom-out"
        case grab
        case grabbing
    }

    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public enum StrokeCap : String, Equatable, Codable {
        case butt
        case round
        case square
    }

    public typealias StrokeDashItem = Double
}

public struct TopLevelFacetedUnitSpec : Equatable, Codable {
    /// An object describing the data source
    public var data: Data
    /// A string describing the mark type (one of `"bar"`, `"circle"`, `"square"`, `"tick"`, `"line"`,
    /// `"area"`, `"point"`, `"rule"`, `"geoshape"`, and `"text"`) or a [mark definition object](https://vega.github.io/vega-lite/docs/mark.html#mark-def).
    public var mark: AnyMark
    /// URL to [JSON schema](http://json-schema.org/) for a Vega-Lite specification. Unless you have a reason to change this, use `https://vega.github.io/schema/vega-lite/v2.json`. Setting the `$schema` property allows automatic validation and autocomplete in editors that support JSON schema.
    public var schema: String?
    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public var autosize: AutosizeChoice?
    /// CSS color property to use as the background of visualization.
    /// __Default value:__ none (transparent)
    public var background: String?
    /// Vega-Lite configuration object.  This property can only be defined at the top-level of a specification.
    public var config: Config?
    /// A global data store for named datasets. This is a mapping from names to inline datasets.
    /// This can be an array of objects or primitive values or a string. Arrays of primitive values are ingested as objects with a `data` property.
    public var datasets: Datasets?
    /// Description of this mark for commenting purpose.
    public var description: String?
    /// A key-value mapping between encoding channels and definition of fields.
    public var encoding: EncodingWithFacet?
    /// The height of a visualization.
    /// __Default value:__
    /// - If a view's [`autosize`](https://vega.github.io/vega-lite/docs/size.html#autosize) type is `"fit"` or its y-channel has a [continuous scale](https://vega.github.io/vega-lite/docs/scale.html#continuous), the height will be the value of [`config.view.height`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - For y-axis with a band or point scale: if [`rangeStep`](https://vega.github.io/vega-lite/docs/scale.html#band) is a numeric value or unspecified, the height is [determined by the range step, paddings, and the cardinality of the field mapped to y-channel](https://vega.github.io/vega-lite/docs/scale.html#band). Otherwise, if the `rangeStep` is `null`, the height will be the value of [`config.view.height`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - If no field is mapped to `y` channel, the `height` will be the value of `rangeStep`.
    /// __Note__: For plots with [`row` and `column` channels](https://vega.github.io/vega-lite/docs/encoding.html#facet), this represents the height of a single view.
    /// __See also:__ The documentation for [width and height](https://vega.github.io/vega-lite/docs/size.html) contains more examples.
    public var height: Double?
    /// Name of the visualization for later reference.
    public var name: String?
    /// The default visualization padding, in pixels, from the edge of the visualization canvas to the data rectangle.  If a number, specifies padding for all sides.
    /// If an object, the value should have the format `{"left": 5, "top": 5, "right": 5, "bottom": 5}` to specify padding for each side of the visualization.
    /// __Default value__: `5`
    public var padding: Padding?
    /// An object defining properties of geographic projection, which will be applied to `shape` path for `"geoshape"` marks
    /// and to `latitude` and `"longitude"` channels for other marks.
    public var projection: Projection?
    /// A key-value mapping between selection names and definitions.
    public var selection: Selection?
    /// Title for the plot.
    public var title: TitleChoice?
    /// An array of data transformations such as filter and new field calculation.
    public var transform: [Transform]?
    /// The width of a visualization.
    /// __Default value:__ This will be determined by the following rules:
    /// - If a view's [`autosize`](https://vega.github.io/vega-lite/docs/size.html#autosize) type is `"fit"` or its x-channel has a [continuous scale](https://vega.github.io/vega-lite/docs/scale.html#continuous), the width will be the value of [`config.view.width`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - For x-axis with a band or point scale: if [`rangeStep`](https://vega.github.io/vega-lite/docs/scale.html#band) is a numeric value or unspecified, the width is [determined by the range step, paddings, and the cardinality of the field mapped to x-channel](https://vega.github.io/vega-lite/docs/scale.html#band).   Otherwise, if the `rangeStep` is `null`, the width will be the value of [`config.view.width`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - If no field is mapped to `x` channel, the `width` will be the value of [`config.scale.textXRangeStep`](https://vega.github.io/vega-lite/docs/size.html#default-width-and-height) for `text` mark and the value of `rangeStep` for other marks.
    /// __Note:__ For plots with [`row` and `column` channels](https://vega.github.io/vega-lite/docs/encoding.html#facet), this represents the width of a single view.
    /// __See also:__ The documentation for [width and height](https://vega.github.io/vega-lite/docs/size.html) contains more examples.
    public var width: Double?

    public init(data: Data, mark: AnyMark, schema: String? = .none, autosize: AutosizeChoice? = .none, background: String? = .none, config: Config? = .none, datasets: Datasets? = .none, description: String? = .none, encoding: EncodingWithFacet? = .none, height: Double? = .none, name: String? = .none, padding: Padding? = .none, projection: Projection? = .none, selection: Selection? = .none, title: TitleChoice? = .none, transform: [Transform]? = .none, width: Double? = .none) {
        self.data = data 
        self.mark = mark 
        self.schema = schema 
        self.autosize = autosize 
        self.background = background 
        self.config = config 
        self.datasets = datasets 
        self.description = description 
        self.encoding = encoding 
        self.height = height 
        self.name = name 
        self.padding = padding 
        self.projection = projection 
        self.selection = selection 
        self.title = title 
        self.transform = transform 
        self.width = width 
    }

    public enum CodingKeys : String, CodingKey {
        case data
        case mark
        case schema = "$schema"
        case autosize
        case background
        case config
        case datasets
        case description
        case encoding
        case height
        case name
        case padding
        case projection
        case selection
        case title
        case transform
        case width
    }

    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public typealias AutosizeChoice = OneOf2<AutosizeType, AutoSizeParams>

    public typealias Selection = Dictionary<String, SelectionValue>
    public typealias SelectionValue = SelectionDef

    /// Title for the plot.
    public typealias TitleChoice = OneOf2<String, TitleParams>
}

public enum AggregateOp : String, Equatable, Codable {
    case argmax
    case argmin
    case average
    case count
    case distinct
    case max
    case mean
    case median
    case min
    case missing
    case q1
    case q3
    case ci0
    case ci1
    case stderr
    case stdev
    case stdevp
    case sum
    case valid
    case values
    case variance
    case variancep
}

/// A FieldDef with Condition<ValueDef>
/// {
///    condition: {value: ...},
///    field: ...,
///    ...
/// }
public struct MarkPropFieldDefWithCondition : Equatable, Codable {
    /// The encoded field's type of measurement (`"quantitative"`, `"temporal"`, `"ordinal"`, or `"nominal"`).
    /// It can also be a `"geojson"` type for encoding ['geoshape'](https://vega.github.io/vega-lite/docs/geoshape.html).
    public var type: `Type`
    /// Aggregation function for the field
    /// (e.g., `mean`, `sum`, `median`, `min`, `max`, `count`).
    /// __Default value:__ `undefined` (None)
    public var aggregate: Aggregate?
    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public var bin: BinChoice?
    /// One or more value definition(s) with a selection predicate.
    /// __Note:__ A field definition's `condition` property can only contain [value definitions](https://vega.github.io/vega-lite/docs/encoding.html#value-def)
    /// since Vega-Lite only allows at most one encoded field per encoding channel.
    public var condition: ConditionChoice?
    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public var field: FieldChoice?
    /// An object defining properties of the legend.
    /// If `null`, the legend for the encoding channel will be removed.
    /// __Default value:__ If undefined, default [legend properties](https://vega.github.io/vega-lite/docs/legend.html) are applied.
    public var legend: LegendChoice?
    /// An object defining properties of the channel's scale, which is the function that transforms values in the data domain (numbers, dates, strings, etc) to visual values (pixels, colors, sizes) of the encoding channels.
    /// If `null`, the scale will be [disabled and the data value will be directly encoded](https://vega.github.io/vega-lite/docs/scale.html#disable).
    /// __Default value:__ If undefined, default [scale properties](https://vega.github.io/vega-lite/docs/scale.html) are applied.
    public var scale: ScaleChoice?
    /// Sort order for the encoded field.
    /// Supported `sort` values include `"ascending"`, `"descending"`, `null` (no sorting), or an array specifying the preferred order of values.
    /// For fields with discrete domains, `sort` can also be a [sort field definition object](https://vega.github.io/vega-lite/docs/sort.html#sort-field).
    /// For `sort` as an [array specifying the preferred order of values](https://vega.github.io/vega-lite/docs/sort.html#sort-array), the sort order will obey the values in the array, followed by any unspecified values in their original order.
    /// __Default value:__ `"ascending"`
    public var sort: SortChoice?
    /// Time unit (e.g., `year`, `yearmonth`, `month`, `hours`) for a temporal field.
    /// or [a temporal field that gets casted as ordinal](https://vega.github.io/vega-lite/docs/type.html#cast).
    /// __Default value:__ `undefined` (None)
    public var timeUnit: TimeUnit?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?

    public init(type: `Type`, aggregate: Aggregate? = .none, bin: BinChoice? = .none, condition: ConditionChoice? = .none, field: FieldChoice? = .none, legend: LegendChoice? = .none, scale: ScaleChoice? = .none, sort: SortChoice? = .none, timeUnit: TimeUnit? = .none, title: Title? = .none) {
        self.type = type 
        self.aggregate = aggregate 
        self.bin = bin 
        self.condition = condition 
        self.field = field 
        self.legend = legend 
        self.scale = scale 
        self.sort = sort 
        self.timeUnit = timeUnit 
        self.title = title 
    }

    public enum CodingKeys : String, CodingKey {
        case type
        case aggregate
        case bin
        case condition
        case field
        case legend
        case scale
        case sort
        case timeUnit
        case title
    }

    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public typealias BinChoice = OneOf2<Bool, BinParams>

    /// One or more value definition(s) with a selection predicate.
    /// __Note:__ A field definition's `condition` property can only contain [value definitions](https://vega.github.io/vega-lite/docs/encoding.html#value-def)
    /// since Vega-Lite only allows at most one encoded field per encoding channel.
    public typealias ConditionChoice = OneOf2<ConditionalValueDef, [ConditionalValueDef]>

    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public typealias FieldChoice = OneOf2<String, RepeatRef>

    /// An object defining properties of the legend.
    /// If `null`, the legend for the encoding channel will be removed.
    /// __Default value:__ If undefined, default [legend properties](https://vega.github.io/vega-lite/docs/legend.html) are applied.
    public typealias LegendChoice = OneOf2<Legend, ExplicitNull>

    /// An object defining properties of the channel's scale, which is the function that transforms values in the data domain (numbers, dates, strings, etc) to visual values (pixels, colors, sizes) of the encoding channels.
    /// If `null`, the scale will be [disabled and the data value will be directly encoded](https://vega.github.io/vega-lite/docs/scale.html#disable).
    /// __Default value:__ If undefined, default [scale properties](https://vega.github.io/vega-lite/docs/scale.html) are applied.
    public typealias ScaleChoice = OneOf2<Scale, ExplicitNull>

    /// Sort order for the encoded field.
    /// Supported `sort` values include `"ascending"`, `"descending"`, `null` (no sorting), or an array specifying the preferred order of values.
    /// For fields with discrete domains, `sort` can also be a [sort field definition object](https://vega.github.io/vega-lite/docs/sort.html#sort-field).
    /// For `sort` as an [array specifying the preferred order of values](https://vega.github.io/vega-lite/docs/sort.html#sort-array), the sort order will obey the values in the array, followed by any unspecified values in their original order.
    /// __Default value:__ `"ascending"`
    public typealias SortChoice = OneOf4<[String], SortOrder, EncodingSortField, ExplicitNull>

    /// A FieldDef with Condition<ValueDef>
    /// {
    ///    condition: {value: ...},
    ///    field: ...,
    ///    ...
    /// }
    public typealias Title = OneOf2<String, ExplicitNull>
}

public struct RepeatSpec : Equatable, Codable {
    /// An object that describes what fields should be repeated into views that are laid out as a `row` or `column`.
    public var `repeat`: Repeat
    public var spec: Spec
    /// An object describing the data source
    public var data: Data?
    /// Description of this mark for commenting purpose.
    public var description: String?
    /// Name of the visualization for later reference.
    public var name: String?
    /// Scale and legend resolutions for repeated charts.
    public var resolve: Resolve?
    /// Title for the plot.
    public var title: TitleChoice?
    /// An array of data transformations such as filter and new field calculation.
    public var transform: [Transform]?

    public init(`repeat`: Repeat, spec: Spec, data: Data? = .none, description: String? = .none, name: String? = .none, resolve: Resolve? = .none, title: TitleChoice? = .none, transform: [Transform]? = .none) {
        self.`repeat` = `repeat` 
        self.spec = spec 
        self.data = data 
        self.description = description 
        self.name = name 
        self.resolve = resolve 
        self.title = title 
        self.transform = transform 
    }

    public enum CodingKeys : String, CodingKey {
        case `repeat` = "repeat"
        case spec
        case data
        case description
        case name
        case resolve
        case title
        case transform
    }

    /// Title for the plot.
    public typealias TitleChoice = OneOf2<String, TitleParams>
}

/// A ValueDef with Condition<ValueDef | FieldDef>
/// {
///    condition: {field: ...} | {value: ...},
///    value: ...,
/// }
public struct MarkPropValueDefWithCondition : Equatable, Codable {
    /// A field definition or one or more value definition(s) with a selection predicate.
    public var condition: ConditionChoice?
    /// A constant value in visual domain.
    public var value: Value?

    public init(condition: ConditionChoice? = .none, value: Value? = .none) {
        self.condition = condition 
        self.value = value 
    }

    public enum CodingKeys : String, CodingKey {
        case condition
        case value
    }

    /// A field definition or one or more value definition(s) with a selection predicate.
    public typealias ConditionChoice = OneOf3<ConditionalMarkPropFieldDef, ConditionalValueDef, [ConditionalValueDef]>

    /// A ValueDef with Condition<ValueDef | FieldDef>
    /// {
    ///    condition: {field: ...} | {value: ...},
    ///    value: ...,
    /// }
    public typealias Value = OneOf3<Double, String, Bool>
}

public typealias LogicalOperandPredicate = OneOf4<LogicalNotPredicate, LogicalAndPredicate, LogicalOrPredicate, Predicate>

public struct ScaleInterpolateParams : Equatable, Codable {
    public var type: `Type`
    public var gamma: Double?

    public init(type: `Type`, gamma: Double? = .none) {
        self.type = type 
        self.gamma = gamma 
    }

    public enum CodingKeys : String, CodingKey {
        case type
        case gamma
    }

    public enum `Type` : String, Equatable, Codable {
        case rgb
        case cubehelix
        case cubehelixLong = "cubehelix-long"
    }
}

public struct SelectionAnd : Equatable, Codable {
    public var and: [SelectionOperand]

    public init(and: [SelectionOperand] = []) {
        self.and = and 
    }

    public enum CodingKeys : String, CodingKey {
        case and
    }
}

/// Definition object for a constant value of an encoding channel.
public struct ValueDef : Equatable, Codable {
    /// A constant value in visual domain (e.g., `"red"` / "#0099ff" for color, values between `0` to `1` for opacity).
    public var value: Value

    public init(value: Value) {
        self.value = value 
    }

    public enum CodingKeys : String, CodingKey {
        case value
    }

    /// Definition object for a constant value of an encoding channel.
    public typealias Value = OneOf3<Double, String, Bool>
}

public struct WindowFieldDef : Equatable, Codable {
    /// The window or aggregation operations to apply within a window, including `rank`, `lead`, `sum`, `average` or `count`. See the list of all supported operations [here](https://vega.github.io/vega-lite/docs/window.html#ops).
    public var op: OpChoice
    /// The output name for the window operation.
    public var `as`: String
    /// The data field for which to compute the aggregate or window function. This can be omitted for window functions that do not operate over a field such as `count`, `rank`, `dense_rank`.
    public var field: String?
    /// Parameter values for the window functions. Parameter values can be omitted for operations that do not accept a parameter.
    /// See the list of all supported operations and their parameters [here](https://vega.github.io/vega-lite/docs/transforms/window.html).
    public var param: Double?

    public init(op: OpChoice, `as`: String, field: String? = .none, param: Double? = .none) {
        self.op = op 
        self.`as` = `as` 
        self.field = field 
        self.param = param 
    }

    public enum CodingKeys : String, CodingKey {
        case op
        case `as` = "as"
        case field
        case param
    }

    /// The window or aggregation operations to apply within a window, including `rank`, `lead`, `sum`, `average` or `count`. See the list of all supported operations [here](https://vega.github.io/vega-lite/docs/window.html#ops).
    public typealias OpChoice = OneOf2<AggregateOp, WindowOnlyOp>
}

public struct ScaleConfig : Equatable, Codable {
    /// Default inner padding for `x` and `y` band-ordinal scales.
    /// __Default value:__ `0.1`
    public var bandPaddingInner: Double?
    /// Default outer padding for `x` and `y` band-ordinal scales.
    /// If not specified, by default, band scale's paddingOuter is paddingInner/2.
    public var bandPaddingOuter: Double?
    /// If true, values that exceed the data domain are clamped to either the minimum or maximum range value
    public var clamp: Bool?
    /// Default padding for continuous scales.
    /// __Default:__ `5` for continuous x-scale of a vertical bar and continuous y-scale of a horizontal bar.; `0` otherwise.
    public var continuousPadding: Double?
    /// The default max value for mapping quantitative fields to bar's size/bandSize.
    /// If undefined (default), we will use the scale's `rangeStep` - 1.
    public var maxBandSize: Double?
    /// The default max value for mapping quantitative fields to text's size/fontSize.
    /// __Default value:__ `40`
    public var maxFontSize: Double?
    /// Default max opacity for mapping a field to opacity.
    /// __Default value:__ `0.8`
    public var maxOpacity: Double?
    /// Default max value for point size scale.
    public var maxSize: Double?
    /// Default max strokeWidth for the scale of strokeWidth for rule and line marks and of size for trail marks.
    /// __Default value:__ `4`
    public var maxStrokeWidth: Double?
    /// The default min value for mapping quantitative fields to bar and tick's size/bandSize scale with zero=false.
    /// __Default value:__ `2`
    public var minBandSize: Double?
    /// The default min value for mapping quantitative fields to tick's size/fontSize scale with zero=false
    /// __Default value:__ `8`
    public var minFontSize: Double?
    /// Default minimum opacity for mapping a field to opacity.
    /// __Default value:__ `0.3`
    public var minOpacity: Double?
    /// Default minimum value for point size scale with zero=false.
    /// __Default value:__ `9`
    public var minSize: Double?
    /// Default minimum strokeWidth for the scale of strokeWidth for rule and line marks and of size for trail marks with zero=false.
    /// __Default value:__ `1`
    public var minStrokeWidth: Double?
    /// Default outer padding for `x` and `y` point-ordinal scales.
    /// __Default value:__ `0.5`
    public var pointPadding: Double?
    /// Default range step for band and point scales of (1) the `y` channel
    /// and (2) the `x` channel when the mark is not `text`.
    /// __Default value:__ `21`
    public var rangeStep: RangeStep?
    /// If true, rounds numeric output values to integers.
    /// This can be helpful for snapping to the pixel grid.
    /// (Only available for `x`, `y`, and `size` scales.)
    public var round: Bool?
    /// Default range step for `x` band and point scales of text marks.
    /// __Default value:__ `90`
    public var textXRangeStep: Double?
    /// Use the source data range before aggregation as scale domain instead of aggregated data for aggregate axis.
    /// This is equivalent to setting `domain` to `"unaggregate"` for aggregated _quantitative_ fields by default.
    /// This property only works with aggregate functions that produce values within the raw data domain (`"mean"`, `"average"`, `"median"`, `"q1"`, `"q3"`, `"min"`, `"max"`). For other aggregations that produce values outside of the raw data domain (e.g. `"count"`, `"sum"`), this property is ignored.
    /// __Default value:__ `false`
    public var useUnaggregatedDomain: Bool?

    public init(bandPaddingInner: Double? = .none, bandPaddingOuter: Double? = .none, clamp: Bool? = .none, continuousPadding: Double? = .none, maxBandSize: Double? = .none, maxFontSize: Double? = .none, maxOpacity: Double? = .none, maxSize: Double? = .none, maxStrokeWidth: Double? = .none, minBandSize: Double? = .none, minFontSize: Double? = .none, minOpacity: Double? = .none, minSize: Double? = .none, minStrokeWidth: Double? = .none, pointPadding: Double? = .none, rangeStep: RangeStep? = .none, round: Bool? = .none, textXRangeStep: Double? = .none, useUnaggregatedDomain: Bool? = .none) {
        self.bandPaddingInner = bandPaddingInner 
        self.bandPaddingOuter = bandPaddingOuter 
        self.clamp = clamp 
        self.continuousPadding = continuousPadding 
        self.maxBandSize = maxBandSize 
        self.maxFontSize = maxFontSize 
        self.maxOpacity = maxOpacity 
        self.maxSize = maxSize 
        self.maxStrokeWidth = maxStrokeWidth 
        self.minBandSize = minBandSize 
        self.minFontSize = minFontSize 
        self.minOpacity = minOpacity 
        self.minSize = minSize 
        self.minStrokeWidth = minStrokeWidth 
        self.pointPadding = pointPadding 
        self.rangeStep = rangeStep 
        self.round = round 
        self.textXRangeStep = textXRangeStep 
        self.useUnaggregatedDomain = useUnaggregatedDomain 
    }

    public enum CodingKeys : String, CodingKey {
        case bandPaddingInner
        case bandPaddingOuter
        case clamp
        case continuousPadding
        case maxBandSize
        case maxFontSize
        case maxOpacity
        case maxSize
        case maxStrokeWidth
        case minBandSize
        case minFontSize
        case minOpacity
        case minSize
        case minStrokeWidth
        case pointPadding
        case rangeStep
        case round
        case textXRangeStep
        case useUnaggregatedDomain
    }

    public typealias RangeStep = OneOf2<Double, ExplicitNull>
}

public struct FieldLTEPredicate : Equatable, Codable {
    /// Field to be filtered.
    public var field: String
    /// The value that the field should be less than or equals to.
    public var lte: LteChoice
    /// Time unit for the field to be filtered.
    public var timeUnit: TimeUnit?

    public init(field: String, lte: LteChoice, timeUnit: TimeUnit? = .none) {
        self.field = field 
        self.lte = lte 
        self.timeUnit = timeUnit 
    }

    public enum CodingKeys : String, CodingKey {
        case field
        case lte
        case timeUnit
    }

    /// The value that the field should be less than or equals to.
    public typealias LteChoice = OneOf3<String, Double, DateTime>
}

public typealias MultiTimeUnit = OneOf2<LocalMultiTimeUnit, UtcMultiTimeUnit>

public struct TopLevelRepeatSpec : Equatable, Codable {
    /// An object that describes what fields should be repeated into views that are laid out as a `row` or `column`.
    public var `repeat`: Repeat
    public var spec: Spec
    /// URL to [JSON schema](http://json-schema.org/) for a Vega-Lite specification. Unless you have a reason to change this, use `https://vega.github.io/schema/vega-lite/v2.json`. Setting the `$schema` property allows automatic validation and autocomplete in editors that support JSON schema.
    public var schema: String?
    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public var autosize: AutosizeChoice?
    /// CSS color property to use as the background of visualization.
    /// __Default value:__ none (transparent)
    public var background: String?
    /// Vega-Lite configuration object.  This property can only be defined at the top-level of a specification.
    public var config: Config?
    /// An object describing the data source
    public var data: Data?
    /// A global data store for named datasets. This is a mapping from names to inline datasets.
    /// This can be an array of objects or primitive values or a string. Arrays of primitive values are ingested as objects with a `data` property.
    public var datasets: Datasets?
    /// Description of this mark for commenting purpose.
    public var description: String?
    /// Name of the visualization for later reference.
    public var name: String?
    /// The default visualization padding, in pixels, from the edge of the visualization canvas to the data rectangle.  If a number, specifies padding for all sides.
    /// If an object, the value should have the format `{"left": 5, "top": 5, "right": 5, "bottom": 5}` to specify padding for each side of the visualization.
    /// __Default value__: `5`
    public var padding: Padding?
    /// Scale and legend resolutions for repeated charts.
    public var resolve: Resolve?
    /// Title for the plot.
    public var title: TitleChoice?
    /// An array of data transformations such as filter and new field calculation.
    public var transform: [Transform]?

    public init(`repeat`: Repeat, spec: Spec, schema: String? = .none, autosize: AutosizeChoice? = .none, background: String? = .none, config: Config? = .none, data: Data? = .none, datasets: Datasets? = .none, description: String? = .none, name: String? = .none, padding: Padding? = .none, resolve: Resolve? = .none, title: TitleChoice? = .none, transform: [Transform]? = .none) {
        self.`repeat` = `repeat` 
        self.spec = spec 
        self.schema = schema 
        self.autosize = autosize 
        self.background = background 
        self.config = config 
        self.data = data 
        self.datasets = datasets 
        self.description = description 
        self.name = name 
        self.padding = padding 
        self.resolve = resolve 
        self.title = title 
        self.transform = transform 
    }

    public enum CodingKeys : String, CodingKey {
        case `repeat` = "repeat"
        case spec
        case schema = "$schema"
        case autosize
        case background
        case config
        case data
        case datasets
        case description
        case name
        case padding
        case resolve
        case title
        case transform
    }

    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public typealias AutosizeChoice = OneOf2<AutosizeType, AutoSizeParams>

    /// Title for the plot.
    public typealias TitleChoice = OneOf2<String, TitleParams>
}

public typealias Transform = OneOf7<FilterTransform, CalculateTransform, LookupTransform, BinTransform, TimeUnitTransform, AggregateTransform, WindowTransform>

public struct VConcatSpec : Equatable, Codable {
    /// A list of views that should be concatenated and put into a column.
    public var vconcat: [Spec]
    /// An object describing the data source
    public var data: Data?
    /// Description of this mark for commenting purpose.
    public var description: String?
    /// Name of the visualization for later reference.
    public var name: String?
    /// Scale, axis, and legend resolutions for vertically concatenated charts.
    public var resolve: Resolve?
    /// Title for the plot.
    public var title: TitleChoice?
    /// An array of data transformations such as filter and new field calculation.
    public var transform: [Transform]?

    public init(vconcat: [Spec] = [], data: Data? = .none, description: String? = .none, name: String? = .none, resolve: Resolve? = .none, title: TitleChoice? = .none, transform: [Transform]? = .none) {
        self.vconcat = vconcat 
        self.data = data 
        self.description = description 
        self.name = name 
        self.resolve = resolve 
        self.title = title 
        self.transform = transform 
    }

    public enum CodingKeys : String, CodingKey {
        case vconcat
        case data
        case description
        case name
        case resolve
        case title
        case transform
    }

    /// Title for the plot.
    public typealias TitleChoice = OneOf2<String, TitleParams>
}

public enum ScaleInterpolate : String, Equatable, Codable {
    case rgb
    case lab
    case hcl
    case hsl
    case hslLong = "hsl-long"
    case hclLong = "hcl-long"
    case cubehelix
    case cubehelixLong = "cubehelix-long"
}

public typealias ConditionalFieldDef = OneOf2<ConditionalPredicateFieldDef, ConditionalSelectionFieldDef>

public struct FacetMapping : Equatable, Codable {
    /// Horizontal facets for trellis plots.
    public var column: FacetFieldDef?
    /// Vertical facets for trellis plots.
    public var row: FacetFieldDef?

    public init(column: FacetFieldDef? = .none, row: FacetFieldDef? = .none) {
        self.column = column 
        self.row = row 
    }

    public enum CodingKeys : String, CodingKey {
        case column
        case row
    }
}

public enum LocalMultiTimeUnit : String, Equatable, Codable {
    case yearquarter
    case yearquartermonth
    case yearmonth
    case yearmonthdate
    case yearmonthdatehours
    case yearmonthdatehoursminutes
    case yearmonthdatehoursminutesseconds
    case quartermonth
    case monthdate
    case hoursminutes
    case hoursminutesseconds
    case minutesseconds
    case secondsmilliseconds
}

public struct TopLevelLayerSpec : Equatable, Codable {
    /// Layer or single view specifications to be layered.
    /// __Note__: Specifications inside `layer` cannot use `row` and `column` channels as layering facet specifications is not allowed.
    public var layer: [LayerItemChoice]
    /// URL to [JSON schema](http://json-schema.org/) for a Vega-Lite specification. Unless you have a reason to change this, use `https://vega.github.io/schema/vega-lite/v2.json`. Setting the `$schema` property allows automatic validation and autocomplete in editors that support JSON schema.
    public var schema: String?
    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public var autosize: AutosizeChoice?
    /// CSS color property to use as the background of visualization.
    /// __Default value:__ none (transparent)
    public var background: String?
    /// Vega-Lite configuration object.  This property can only be defined at the top-level of a specification.
    public var config: Config?
    /// An object describing the data source
    public var data: Data?
    /// A global data store for named datasets. This is a mapping from names to inline datasets.
    /// This can be an array of objects or primitive values or a string. Arrays of primitive values are ingested as objects with a `data` property.
    public var datasets: Datasets?
    /// Description of this mark for commenting purpose.
    public var description: String?
    /// A shared key-value mapping between encoding channels and definition of fields in the underlying layers.
    public var encoding: Encoding?
    /// The height of a visualization.
    /// __Default value:__
    /// - If a view's [`autosize`](https://vega.github.io/vega-lite/docs/size.html#autosize) type is `"fit"` or its y-channel has a [continuous scale](https://vega.github.io/vega-lite/docs/scale.html#continuous), the height will be the value of [`config.view.height`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - For y-axis with a band or point scale: if [`rangeStep`](https://vega.github.io/vega-lite/docs/scale.html#band) is a numeric value or unspecified, the height is [determined by the range step, paddings, and the cardinality of the field mapped to y-channel](https://vega.github.io/vega-lite/docs/scale.html#band). Otherwise, if the `rangeStep` is `null`, the height will be the value of [`config.view.height`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - If no field is mapped to `y` channel, the `height` will be the value of `rangeStep`.
    /// __Note__: For plots with [`row` and `column` channels](https://vega.github.io/vega-lite/docs/encoding.html#facet), this represents the height of a single view.
    /// __See also:__ The documentation for [width and height](https://vega.github.io/vega-lite/docs/size.html) contains more examples.
    public var height: Double?
    /// Name of the visualization for later reference.
    public var name: String?
    /// The default visualization padding, in pixels, from the edge of the visualization canvas to the data rectangle.  If a number, specifies padding for all sides.
    /// If an object, the value should have the format `{"left": 5, "top": 5, "right": 5, "bottom": 5}` to specify padding for each side of the visualization.
    /// __Default value__: `5`
    public var padding: Padding?
    /// An object defining properties of the geographic projection shared by underlying layers.
    public var projection: Projection?
    /// Scale, axis, and legend resolutions for layers.
    public var resolve: Resolve?
    /// Title for the plot.
    public var title: TitleChoice?
    /// An array of data transformations such as filter and new field calculation.
    public var transform: [Transform]?
    /// The width of a visualization.
    /// __Default value:__ This will be determined by the following rules:
    /// - If a view's [`autosize`](https://vega.github.io/vega-lite/docs/size.html#autosize) type is `"fit"` or its x-channel has a [continuous scale](https://vega.github.io/vega-lite/docs/scale.html#continuous), the width will be the value of [`config.view.width`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - For x-axis with a band or point scale: if [`rangeStep`](https://vega.github.io/vega-lite/docs/scale.html#band) is a numeric value or unspecified, the width is [determined by the range step, paddings, and the cardinality of the field mapped to x-channel](https://vega.github.io/vega-lite/docs/scale.html#band).   Otherwise, if the `rangeStep` is `null`, the width will be the value of [`config.view.width`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - If no field is mapped to `x` channel, the `width` will be the value of [`config.scale.textXRangeStep`](https://vega.github.io/vega-lite/docs/size.html#default-width-and-height) for `text` mark and the value of `rangeStep` for other marks.
    /// __Note:__ For plots with [`row` and `column` channels](https://vega.github.io/vega-lite/docs/encoding.html#facet), this represents the width of a single view.
    /// __See also:__ The documentation for [width and height](https://vega.github.io/vega-lite/docs/size.html) contains more examples.
    public var width: Double?

    public init(layer: [LayerItemChoice] = [], schema: String? = .none, autosize: AutosizeChoice? = .none, background: String? = .none, config: Config? = .none, data: Data? = .none, datasets: Datasets? = .none, description: String? = .none, encoding: Encoding? = .none, height: Double? = .none, name: String? = .none, padding: Padding? = .none, projection: Projection? = .none, resolve: Resolve? = .none, title: TitleChoice? = .none, transform: [Transform]? = .none, width: Double? = .none) {
        self.layer = layer 
        self.schema = schema 
        self.autosize = autosize 
        self.background = background 
        self.config = config 
        self.data = data 
        self.datasets = datasets 
        self.description = description 
        self.encoding = encoding 
        self.height = height 
        self.name = name 
        self.padding = padding 
        self.projection = projection 
        self.resolve = resolve 
        self.title = title 
        self.transform = transform 
        self.width = width 
    }

    public enum CodingKeys : String, CodingKey {
        case layer
        case schema = "$schema"
        case autosize
        case background
        case config
        case data
        case datasets
        case description
        case encoding
        case height
        case name
        case padding
        case projection
        case resolve
        case title
        case transform
        case width
    }

    public typealias LayerItemChoice = OneOf2<LayerSpec, CompositeUnitSpec>

    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public typealias AutosizeChoice = OneOf2<AutosizeType, AutoSizeParams>

    /// Title for the plot.
    public typealias TitleChoice = OneOf2<String, TitleParams>
}

public typealias ProjectionType = VgProjectionType

public struct AreaConfig : Equatable, Codable {
    /// The horizontal alignment of the text. One of `"left"`, `"right"`, `"center"`.
    public var align: HorizontalAlign?
    /// The rotation angle of the text, in degrees.
    public var angle: Double?
    /// The vertical alignment of the text. One of `"top"`, `"middle"`, `"bottom"`.
    /// __Default value:__ `"middle"`
    public var baseline: VerticalAlign?
    /// Default color.  Note that `fill` and `stroke` have higher precedence than `color` and will override `color`.
    /// __Default value:__ <span style="color: #4682b4;">&#9632;</span> `"#4682b4"`
    /// __Note:__ This property cannot be used in a [style config](https://vega.github.io/vega-lite/docs/mark.html#style-config).
    public var color: String?
    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public var cursor: Cursor?
    /// The horizontal offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dx: Double?
    /// The vertical offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dy: Double?
    /// Default Fill Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var fill: String?
    /// The fill opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var fillOpacity: Double?
    /// Whether the mark's color should be used as fill color instead of stroke color.
    /// __Default value:__ `true` for all marks except `point` and `false` for `point`.
    /// __Applicable for:__ `bar`, `point`, `circle`, `square`, and `area` marks.
    /// __Note:__ This property cannot be used in a [style config](https://vega.github.io/vega-lite/docs/mark.html#style-config).
    public var filled: Bool?
    /// The typeface to set the text in (e.g., `"Helvetica Neue"`).
    public var font: String?
    /// The font size, in pixels.
    public var fontSize: Double?
    /// The font style (e.g., `"italic"`).
    public var fontStyle: FontStyle?
    /// The font weight.
    /// This can be either a string (e.g `"bold"`, `"normal"`) or a number (`100`, `200`, `300`, ..., `900` where `"normal"` = `400` and `"bold"` = `700`).
    public var fontWeight: FontWeight?
    /// A URL to load upon mouse click. If defined, the mark acts as a hyperlink.
    public var href: String?
    /// The line interpolation method to use for line and area marks. One of the following:
    /// - `"linear"`: piecewise linear segments, as in a polyline.
    /// - `"linear-closed"`: close the linear segments to form a polygon.
    /// - `"step"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"step-before"`: alternate between vertical and horizontal segments, as in a step function.
    /// - `"step-after"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"basis"`: a B-spline, with control point duplication on the ends.
    /// - `"basis-open"`: an open B-spline; may not intersect the start or end.
    /// - `"basis-closed"`: a closed B-spline, as in a loop.
    /// - `"cardinal"`: a Cardinal spline, with control point duplication on the ends.
    /// - `"cardinal-open"`: an open Cardinal spline; may not intersect the start or end, but will intersect other control points.
    /// - `"cardinal-closed"`: a closed Cardinal spline, as in a loop.
    /// - `"bundle"`: equivalent to basis, except the tension parameter is used to straighten the spline.
    /// - `"monotone"`: cubic interpolation that preserves monotonicity in y.
    public var interpolate: Interpolate?
    /// The maximum length of the text mark in pixels (default 0, indicating no limit). The text value will be automatically truncated if the rendered size exceeds the limit.
    public var limit: Double?
    /// A flag for overlaying line on top of area marks, or an object defining the properties of the overlayed lines.
    /// - If this value is an empty object (`{}`) or `true`, lines with default properties will be used.
    /// - If this value is `false`, no lines would be automatically added to area marks.
    /// __Default value:__ `false`.
    public var line: LineChoice?
    /// The overall opacity (value between [0,1]).
    /// __Default value:__ `0.7` for non-aggregate plots with `point`, `tick`, `circle`, or `square` marks or layered `bar` charts and `1` otherwise.
    public var opacity: Double?
    /// The orientation of a non-stacked bar, tick, area, and line charts.
    /// The value is either horizontal (default) or vertical.
    /// - For bar, rule and tick, this determines whether the size of the bar and tick
    /// should be applied to x or y dimension.
    /// - For area, this property determines the orient property of the Vega output.
    /// - For line and trail marks, this property determines the sort order of the points in the line
    /// if `config.sortLineBy` is not specified.
    /// For stacked charts, this is always determined by the orientation of the stack;
    /// therefore explicitly specified value will be ignored.
    public var orient: Orient?
    /// A flag for overlaying points on top of line or area marks, or an object defining the properties of the overlayed points.
    /// - If this property is `"transparent"`, transparent points will be used (for enhancing tooltips and selections).
    /// - If this property is an empty object (`{}`) or `true`, filled points with default properties will be used.
    /// - If this property is `false`, no points would be automatically added to line or area marks.
    /// __Default value:__ `false`.
    public var point: PointChoice?
    /// Polar coordinate radial offset, in pixels, of the text label from the origin determined by the `x` and `y` properties.
    public var radius: Double?
    /// The default symbol shape to use. One of: `"circle"` (default), `"square"`, `"cross"`, `"diamond"`, `"triangle-up"`, or `"triangle-down"`, or a custom SVG path.
    /// __Default value:__ `"circle"`
    public var shape: String?
    /// The pixel area each the point/circle/square.
    /// For example: in the case of circles, the radius is determined in part by the square root of the size value.
    /// __Default value:__ `30`
    public var size: Double?
    /// Default Stroke Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var stroke: String?
    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public var strokeCap: StrokeCap?
    /// An array of alternating stroke, space lengths for creating dashed or dotted lines.
    public var strokeDash: [StrokeDashItem]?
    /// The offset (in pixels) into which to begin drawing with the stroke dash array.
    public var strokeDashOffset: Double?
    /// The stroke opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var strokeOpacity: Double?
    /// The stroke width, in pixels.
    public var strokeWidth: Double?
    /// Depending on the interpolation type, sets the tension parameter (for line and area marks).
    public var tension: Double?
    /// Placeholder text if the `text` channel is not specified
    public var text: String?
    /// Polar coordinate angle, in radians, of the text label from the origin determined by the `x` and `y` properties. Values for `theta` follow the same convention of `arc` mark `startAngle` and `endAngle` properties: angles are measured in radians, with `0` indicating "north".
    public var theta: Double?

    public init(align: HorizontalAlign? = .none, angle: Double? = .none, baseline: VerticalAlign? = .none, color: String? = .none, cursor: Cursor? = .none, dx: Double? = .none, dy: Double? = .none, fill: String? = .none, fillOpacity: Double? = .none, filled: Bool? = .none, font: String? = .none, fontSize: Double? = .none, fontStyle: FontStyle? = .none, fontWeight: FontWeight? = .none, href: String? = .none, interpolate: Interpolate? = .none, limit: Double? = .none, line: LineChoice? = .none, opacity: Double? = .none, orient: Orient? = .none, point: PointChoice? = .none, radius: Double? = .none, shape: String? = .none, size: Double? = .none, stroke: String? = .none, strokeCap: StrokeCap? = .none, strokeDash: [StrokeDashItem]? = .none, strokeDashOffset: Double? = .none, strokeOpacity: Double? = .none, strokeWidth: Double? = .none, tension: Double? = .none, text: String? = .none, theta: Double? = .none) {
        self.align = align 
        self.angle = angle 
        self.baseline = baseline 
        self.color = color 
        self.cursor = cursor 
        self.dx = dx 
        self.dy = dy 
        self.fill = fill 
        self.fillOpacity = fillOpacity 
        self.filled = filled 
        self.font = font 
        self.fontSize = fontSize 
        self.fontStyle = fontStyle 
        self.fontWeight = fontWeight 
        self.href = href 
        self.interpolate = interpolate 
        self.limit = limit 
        self.line = line 
        self.opacity = opacity 
        self.orient = orient 
        self.point = point 
        self.radius = radius 
        self.shape = shape 
        self.size = size 
        self.stroke = stroke 
        self.strokeCap = strokeCap 
        self.strokeDash = strokeDash 
        self.strokeDashOffset = strokeDashOffset 
        self.strokeOpacity = strokeOpacity 
        self.strokeWidth = strokeWidth 
        self.tension = tension 
        self.text = text 
        self.theta = theta 
    }

    public enum CodingKeys : String, CodingKey {
        case align
        case angle
        case baseline
        case color
        case cursor
        case dx
        case dy
        case fill
        case fillOpacity
        case filled
        case font
        case fontSize
        case fontStyle
        case fontWeight
        case href
        case interpolate
        case limit
        case line
        case opacity
        case orient
        case point
        case radius
        case shape
        case size
        case stroke
        case strokeCap
        case strokeDash
        case strokeDashOffset
        case strokeOpacity
        case strokeWidth
        case tension
        case text
        case theta
    }

    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public enum Cursor : String, Equatable, Codable {
        case auto
        case `default` = "default"
        case none
        case contextMenu = "context-menu"
        case help
        case pointer
        case progress
        case wait
        case cell
        case crosshair
        case text
        case verticalText = "vertical-text"
        case alias
        case copy
        case move
        case noDrop = "no-drop"
        case notAllowed = "not-allowed"
        case eResize = "e-resize"
        case nResize = "n-resize"
        case neResize = "ne-resize"
        case nwResize = "nw-resize"
        case sResize = "s-resize"
        case seResize = "se-resize"
        case swResize = "sw-resize"
        case wResize = "w-resize"
        case ewResize = "ew-resize"
        case nsResize = "ns-resize"
        case neswResize = "nesw-resize"
        case nwseResize = "nwse-resize"
        case colResize = "col-resize"
        case rowResize = "row-resize"
        case allScroll = "all-scroll"
        case zoomIn = "zoom-in"
        case zoomOut = "zoom-out"
        case grab
        case grabbing
    }

    /// A flag for overlaying line on top of area marks, or an object defining the properties of the overlayed lines.
    /// - If this value is an empty object (`{}`) or `true`, lines with default properties will be used.
    /// - If this value is `false`, no lines would be automatically added to area marks.
    /// __Default value:__ `false`.
    public typealias LineChoice = OneOf2<Bool, MarkConfig>

    /// A flag for overlaying points on top of line or area marks, or an object defining the properties of the overlayed points.
    /// - If this property is `"transparent"`, transparent points will be used (for enhancing tooltips and selections).
    /// - If this property is an empty object (`{}`) or `true`, filled points with default properties will be used.
    /// - If this property is `false`, no points would be automatically added to line or area marks.
    /// __Default value:__ `false`.
    public typealias PointChoice = PointTypes.Choice
    public enum PointTypes {

        public typealias Choice = OneOf3<Bool, MarkConfig, Type3>

        public enum Type3 : String, Equatable, Codable {
            case transparent
        }
    }

    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public enum StrokeCap : String, Equatable, Codable {
        case butt
        case round
        case square
    }

    public typealias StrokeDashItem = Double
}

public enum GeoType : String, Equatable, Codable {
    case latitude
    case longitude
    case geojson
}

public typealias Data = OneOf3<UrlData, InlineData, NamedData>

/// A FieldDef with Condition<ValueDef>
/// {
///    condition: {value: ...},
///    field: ...,
///    ...
/// }
public struct FieldDefWithCondition : Equatable, Codable {
    /// The encoded field's type of measurement (`"quantitative"`, `"temporal"`, `"ordinal"`, or `"nominal"`).
    /// It can also be a `"geojson"` type for encoding ['geoshape'](https://vega.github.io/vega-lite/docs/geoshape.html).
    public var type: `Type`
    /// Aggregation function for the field
    /// (e.g., `mean`, `sum`, `median`, `min`, `max`, `count`).
    /// __Default value:__ `undefined` (None)
    public var aggregate: Aggregate?
    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public var bin: BinChoice?
    /// One or more value definition(s) with a selection predicate.
    /// __Note:__ A field definition's `condition` property can only contain [value definitions](https://vega.github.io/vega-lite/docs/encoding.html#value-def)
    /// since Vega-Lite only allows at most one encoded field per encoding channel.
    public var condition: ConditionChoice?
    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public var field: FieldChoice?
    /// Time unit (e.g., `year`, `yearmonth`, `month`, `hours`) for a temporal field.
    /// or [a temporal field that gets casted as ordinal](https://vega.github.io/vega-lite/docs/type.html#cast).
    /// __Default value:__ `undefined` (None)
    public var timeUnit: TimeUnit?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?

    public init(type: `Type`, aggregate: Aggregate? = .none, bin: BinChoice? = .none, condition: ConditionChoice? = .none, field: FieldChoice? = .none, timeUnit: TimeUnit? = .none, title: Title? = .none) {
        self.type = type 
        self.aggregate = aggregate 
        self.bin = bin 
        self.condition = condition 
        self.field = field 
        self.timeUnit = timeUnit 
        self.title = title 
    }

    public enum CodingKeys : String, CodingKey {
        case type
        case aggregate
        case bin
        case condition
        case field
        case timeUnit
        case title
    }

    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public typealias BinChoice = OneOf2<Bool, BinParams>

    /// One or more value definition(s) with a selection predicate.
    /// __Note:__ A field definition's `condition` property can only contain [value definitions](https://vega.github.io/vega-lite/docs/encoding.html#value-def)
    /// since Vega-Lite only allows at most one encoded field per encoding channel.
    public typealias ConditionChoice = OneOf2<ConditionalValueDef, [ConditionalValueDef]>

    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public typealias FieldChoice = OneOf2<String, RepeatRef>

    /// A FieldDef with Condition<ValueDef>
    /// {
    ///    condition: {value: ...},
    ///    field: ...,
    ///    ...
    /// }
    public typealias Title = OneOf2<String, ExplicitNull>
}

public enum Interpolate : String, Equatable, Codable {
    case linear
    case linearClosed = "linear-closed"
    case step
    case stepBefore = "step-before"
    case stepAfter = "step-after"
    case basis
    case basisOpen = "basis-open"
    case basisClosed = "basis-closed"
    case cardinal
    case cardinalOpen = "cardinal-open"
    case cardinalClosed = "cardinal-closed"
    case bundle
    case monotone
}

public typealias SingleTimeUnit = OneOf2<LocalSingleTimeUnit, UtcSingleTimeUnit>

public struct Repeat : Equatable, Codable {
    /// Horizontal repeated views.
    public var column: [ColumnItem]?
    /// Vertical repeated views.
    public var row: [RowItem]?

    public init(column: [ColumnItem]? = .none, row: [RowItem]? = .none) {
        self.column = column 
        self.row = row 
    }

    public enum CodingKeys : String, CodingKey {
        case column
        case row
    }

    public typealias ColumnItem = String

    public typealias RowItem = String
}

/// Object for defining datetime in Vega-Lite Filter.
/// If both month and quarter are provided, month has higher precedence.
/// `day` cannot be combined with other date.
/// We accept string for month and day names.
public struct DateTime : Equatable, Codable {
    /// Integer value representing the date from 1-31.
    public var date: Double?
    /// Value representing the day of a week.  This can be one of: (1) integer value -- `1` represents Monday; (2) case-insensitive day name (e.g., `"Monday"`);  (3) case-insensitive, 3-character short day name (e.g., `"Mon"`).   <br/> **Warning:** A DateTime definition object with `day`** should not be combined with `year`, `quarter`, `month`, or `date`.
    public var day: DayChoice?
    /// Integer value representing the hour of a day from 0-23.
    public var hours: Double?
    /// Integer value representing the millisecond segment of time.
    public var milliseconds: Double?
    /// Integer value representing the minute segment of time from 0-59.
    public var minutes: Double?
    /// One of: (1) integer value representing the month from `1`-`12`. `1` represents January;  (2) case-insensitive month name (e.g., `"January"`);  (3) case-insensitive, 3-character short month name (e.g., `"Jan"`). 
    public var month: MonthChoice?
    /// Integer value representing the quarter of the year (from 1-4).
    public var quarter: Double?
    /// Integer value representing the second segment (0-59) of a time value
    public var seconds: Double?
    /// A boolean flag indicating if date time is in utc time. If false, the date time is in local time
    public var utc: Bool?
    /// Integer value representing the year.
    public var year: Double?

    public init(date: Double? = .none, day: DayChoice? = .none, hours: Double? = .none, milliseconds: Double? = .none, minutes: Double? = .none, month: MonthChoice? = .none, quarter: Double? = .none, seconds: Double? = .none, utc: Bool? = .none, year: Double? = .none) {
        self.date = date 
        self.day = day 
        self.hours = hours 
        self.milliseconds = milliseconds 
        self.minutes = minutes 
        self.month = month 
        self.quarter = quarter 
        self.seconds = seconds 
        self.utc = utc 
        self.year = year 
    }

    public enum CodingKeys : String, CodingKey {
        case date
        case day
        case hours
        case milliseconds
        case minutes
        case month
        case quarter
        case seconds
        case utc
        case year
    }

    /// Value representing the day of a week.  This can be one of: (1) integer value -- `1` represents Monday; (2) case-insensitive day name (e.g., `"Monday"`);  (3) case-insensitive, 3-character short day name (e.g., `"Mon"`).   <br/> **Warning:** A DateTime definition object with `day`** should not be combined with `year`, `quarter`, `month`, or `date`.
    public typealias DayChoice = OneOf2<Day, String>

    /// One of: (1) integer value representing the month from `1`-`12`. `1` represents January;  (2) case-insensitive month name (e.g., `"January"`);  (3) case-insensitive, 3-character short month name (e.g., `"Jan"`). 
    public typealias MonthChoice = OneOf2<Month, String>
}

public typealias SelectionDomain = SelectionDomainTypes.Choice
public enum SelectionDomainTypes {

    public typealias Choice = OneOf2<SelectionFieldType, SelectionEncodingType>

    public struct SelectionFieldType : Equatable, Codable {
        /// The name of a selection.
        public var selection: String
        /// The field name to extract selected values for, when a selection is [projected](https://vega.github.io/vega-lite/docs/project.html)
        /// over multiple fields or encodings.
        public var field: String?

        public init(selection: String, field: String? = .none) {
            self.selection = selection 
            self.field = field 
        }

        public enum CodingKeys : String, CodingKey {
            case selection
            case field
        }
    }

    public struct SelectionEncodingType : Equatable, Codable {
        /// The name of a selection.
        public var selection: String
        /// The encoding channel to extract selected values for, when a selection is [projected](https://vega.github.io/vega-lite/docs/project.html)
        /// over multiple fields or encodings.
        public var encoding: String?

        public init(selection: String, encoding: String? = .none) {
            self.selection = selection 
            self.encoding = encoding 
        }

        public enum CodingKeys : String, CodingKey {
            case selection
            case encoding
        }
    }
}

/// A sort definition for sorting a discrete scale in an encoding field definition.
public struct EncodingSortField : Equatable, Codable {
    /// An [aggregate operation](https://vega.github.io/vega-lite/docs/aggregate.html#ops) to perform on the field prior to sorting (e.g., `"count"`, `"mean"` and `"median"`).
    /// This property is required in cases where the sort field and the data reference field do not match.
    /// The input data objects will be aggregated, grouped by the encoded data field.
    /// For a full list of operations, please see the documentation for [aggregate](https://vega.github.io/vega-lite/docs/aggregate.html#ops).
    public var op: AggregateOp
    /// The data [field](https://vega.github.io/vega-lite/docs/field.html) to sort by.
    /// __Default value:__ If unspecified, defaults to the field specified in the outer data reference.
    public var field: FieldChoice?
    /// The sort order. One of `"ascending"` (default), `"descending"`, or `null` (no not sort).
    public var order: SortOrder?

    public init(op: AggregateOp, field: FieldChoice? = .none, order: SortOrder? = .none) {
        self.op = op 
        self.field = field 
        self.order = order 
    }

    public enum CodingKeys : String, CodingKey {
        case op
        case field
        case order
    }

    /// The data [field](https://vega.github.io/vega-lite/docs/field.html) to sort by.
    /// __Default value:__ If unspecified, defaults to the field specified in the outer data reference.
    public typealias FieldChoice = OneOf2<String, RepeatRef>
}

public struct FilterTransform : Equatable, Codable {
    /// The `filter` property must be one of the predicate definitions:
    /// 1) an [expression](https://vega.github.io/vega-lite/docs/types.html#expression) string,
    /// where `datum` can be used to refer to the current data object
    /// 2) one of the field predicates: [`equal`](https://vega.github.io/vega-lite/docs/filter.html#equal-predicate),
    /// [`lt`](https://vega.github.io/vega-lite/docs/filter.html#lt-predicate),
    /// [`lte`](https://vega.github.io/vega-lite/docs/filter.html#lte-predicate),
    /// [`gt`](https://vega.github.io/vega-lite/docs/filter.html#gt-predicate),
    /// [`gte`](https://vega.github.io/vega-lite/docs/filter.html#gte-predicate),
    /// [`range`](https://vega.github.io/vega-lite/docs/filter.html#range-predicate),
    /// or [`oneOf`](https://vega.github.io/vega-lite/docs/filter.html#one-of-predicate).
    /// 3) a [selection predicate](https://vega.github.io/vega-lite/docs/filter.html#selection-predicate)
    /// 4) a logical operand that combines (1), (2), or (3).
    public var filter: LogicalOperandPredicate

    public init(filter: LogicalOperandPredicate) {
        self.filter = filter 
    }

    public enum CodingKeys : String, CodingKey {
        case filter
    }
}

public struct LogicalOrPredicate : Equatable, Codable {
    public var or: [LogicalOperandPredicate]

    public init(or: [LogicalOperandPredicate] = []) {
        self.or = or 
    }

    public enum CodingKeys : String, CodingKey {
        case or
    }
}

public struct VgTitleConfig : Equatable, Codable {
    /// The anchor position for placing the title. One of `"start"`, `"middle"`, or `"end"`. For example, with an orientation of top these anchor positions map to a left-, center-, or right-aligned title.
    /// __Default value:__ `"middle"` for [single](https://vega.github.io/vega-lite/docs/spec.html) and [layered](https://vega.github.io/vega-lite/docs/layer.html) views.
    /// `"start"` for other composite views.
    /// __Note:__ [For now](https://github.com/vega/vega-lite/issues/2875), `anchor` is only customizable only for [single](https://vega.github.io/vega-lite/docs/spec.html) and [layered](https://vega.github.io/vega-lite/docs/layer.html) views.  For other composite views, `anchor` is always `"start"`.
    public var anchor: Anchor?
    /// Angle in degrees of title text.
    public var angle: Double?
    /// Vertical text baseline for title text.
    public var baseline: VerticalAlign?
    /// Text color for title text.
    public var color: String?
    /// Font name for title text.
    public var font: String?
    /// Font size in pixels for title text.
    /// __Default value:__ `10`.
    public var fontSize: Double?
    /// Font weight for title text.
    /// This can be either a string (e.g `"bold"`, `"normal"`) or a number (`100`, `200`, `300`, ..., `900` where `"normal"` = `400` and `"bold"` = `700`).
    public var fontWeight: FontWeight?
    /// The maximum allowed length in pixels of legend labels.
    public var limit: Double?
    /// Offset in pixels of the title from the chart body and axes.
    public var offset: Double?
    /// Default title orientation ("top", "bottom", "left", or "right")
    public var orient: TitleOrient?

    public init(anchor: Anchor? = .none, angle: Double? = .none, baseline: VerticalAlign? = .none, color: String? = .none, font: String? = .none, fontSize: Double? = .none, fontWeight: FontWeight? = .none, limit: Double? = .none, offset: Double? = .none, orient: TitleOrient? = .none) {
        self.anchor = anchor 
        self.angle = angle 
        self.baseline = baseline 
        self.color = color 
        self.font = font 
        self.fontSize = fontSize 
        self.fontWeight = fontWeight 
        self.limit = limit 
        self.offset = offset 
        self.orient = orient 
    }

    public enum CodingKeys : String, CodingKey {
        case anchor
        case angle
        case baseline
        case color
        case font
        case fontSize
        case fontWeight
        case limit
        case offset
        case orient
    }
}

public enum Anchor : String, Equatable, Codable {
    case start
    case middle
    case end
}

public struct CompositeUnitSpecAlias : Equatable, Codable {
    /// A string describing the mark type (one of `"bar"`, `"circle"`, `"square"`, `"tick"`, `"line"`,
    /// `"area"`, `"point"`, `"rule"`, `"geoshape"`, and `"text"`) or a [mark definition object](https://vega.github.io/vega-lite/docs/mark.html#mark-def).
    public var mark: AnyMark
    /// An object describing the data source
    public var data: Data?
    /// Description of this mark for commenting purpose.
    public var description: String?
    /// A key-value mapping between encoding channels and definition of fields.
    public var encoding: Encoding?
    /// The height of a visualization.
    /// __Default value:__
    /// - If a view's [`autosize`](https://vega.github.io/vega-lite/docs/size.html#autosize) type is `"fit"` or its y-channel has a [continuous scale](https://vega.github.io/vega-lite/docs/scale.html#continuous), the height will be the value of [`config.view.height`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - For y-axis with a band or point scale: if [`rangeStep`](https://vega.github.io/vega-lite/docs/scale.html#band) is a numeric value or unspecified, the height is [determined by the range step, paddings, and the cardinality of the field mapped to y-channel](https://vega.github.io/vega-lite/docs/scale.html#band). Otherwise, if the `rangeStep` is `null`, the height will be the value of [`config.view.height`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - If no field is mapped to `y` channel, the `height` will be the value of `rangeStep`.
    /// __Note__: For plots with [`row` and `column` channels](https://vega.github.io/vega-lite/docs/encoding.html#facet), this represents the height of a single view.
    /// __See also:__ The documentation for [width and height](https://vega.github.io/vega-lite/docs/size.html) contains more examples.
    public var height: Double?
    /// Name of the visualization for later reference.
    public var name: String?
    /// An object defining properties of geographic projection, which will be applied to `shape` path for `"geoshape"` marks
    /// and to `latitude` and `"longitude"` channels for other marks.
    public var projection: Projection?
    /// A key-value mapping between selection names and definitions.
    public var selection: Selection?
    /// Title for the plot.
    public var title: TitleChoice?
    /// An array of data transformations such as filter and new field calculation.
    public var transform: [Transform]?
    /// The width of a visualization.
    /// __Default value:__ This will be determined by the following rules:
    /// - If a view's [`autosize`](https://vega.github.io/vega-lite/docs/size.html#autosize) type is `"fit"` or its x-channel has a [continuous scale](https://vega.github.io/vega-lite/docs/scale.html#continuous), the width will be the value of [`config.view.width`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - For x-axis with a band or point scale: if [`rangeStep`](https://vega.github.io/vega-lite/docs/scale.html#band) is a numeric value or unspecified, the width is [determined by the range step, paddings, and the cardinality of the field mapped to x-channel](https://vega.github.io/vega-lite/docs/scale.html#band).   Otherwise, if the `rangeStep` is `null`, the width will be the value of [`config.view.width`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - If no field is mapped to `x` channel, the `width` will be the value of [`config.scale.textXRangeStep`](https://vega.github.io/vega-lite/docs/size.html#default-width-and-height) for `text` mark and the value of `rangeStep` for other marks.
    /// __Note:__ For plots with [`row` and `column` channels](https://vega.github.io/vega-lite/docs/encoding.html#facet), this represents the width of a single view.
    /// __See also:__ The documentation for [width and height](https://vega.github.io/vega-lite/docs/size.html) contains more examples.
    public var width: Double?

    public init(mark: AnyMark, data: Data? = .none, description: String? = .none, encoding: Encoding? = .none, height: Double? = .none, name: String? = .none, projection: Projection? = .none, selection: Selection? = .none, title: TitleChoice? = .none, transform: [Transform]? = .none, width: Double? = .none) {
        self.mark = mark 
        self.data = data 
        self.description = description 
        self.encoding = encoding 
        self.height = height 
        self.name = name 
        self.projection = projection 
        self.selection = selection 
        self.title = title 
        self.transform = transform 
        self.width = width 
    }

    public enum CodingKeys : String, CodingKey {
        case mark
        case data
        case description
        case encoding
        case height
        case name
        case projection
        case selection
        case title
        case transform
        case width
    }

    public typealias Selection = Dictionary<String, SelectionValue>
    public typealias SelectionValue = SelectionDef

    /// Title for the plot.
    public typealias TitleChoice = OneOf2<String, TitleParams>
}

public typealias ConditionalMarkPropFieldDef = OneOf2<ConditionalPredicateMarkPropFieldDef, ConditionalSelectionMarkPropFieldDef>

public typealias TopLevelSpec = OneOf6<TopLevelFacetedUnitSpec, TopLevelFacetSpec, TopLevelLayerSpec, TopLevelRepeatSpec, TopLevelVConcatSpec, TopLevelHConcatSpec>

public struct SelectionOr : Equatable, Codable {
    public var or: [SelectionOperand]

    public init(or: [SelectionOperand] = []) {
        self.or = or 
    }

    public enum CodingKeys : String, CodingKey {
        case or
    }
}

/// A ValueDef with Condition<ValueDef | FieldDef>
/// {
///    condition: {field: ...} | {value: ...},
///    value: ...,
/// }
public struct ValueDefWithCondition : Equatable, Codable {
    /// A field definition or one or more value definition(s) with a selection predicate.
    public var condition: ConditionChoice?
    /// A constant value in visual domain.
    public var value: Value?

    public init(condition: ConditionChoice? = .none, value: Value? = .none) {
        self.condition = condition 
        self.value = value 
    }

    public enum CodingKeys : String, CodingKey {
        case condition
        case value
    }

    /// A field definition or one or more value definition(s) with a selection predicate.
    public typealias ConditionChoice = OneOf3<ConditionalFieldDef, ConditionalValueDef, [ConditionalValueDef]>

    /// A ValueDef with Condition<ValueDef | FieldDef>
    /// {
    ///    condition: {field: ...} | {value: ...},
    ///    value: ...,
    /// }
    public typealias Value = OneOf3<Double, String, Bool>
}

public typealias CompositeUnitSpec = CompositeUnitSpecAlias

public enum StackOffset : String, Equatable, Codable {
    case zero
    case center
    case normalize
}

/// Any property of Projection can be in config
public struct ProjectionConfig : Equatable, Codable {
    /// Sets the projection’s center to the specified center, a two-element array of longitude and latitude in degrees.
    /// __Default value:__ `[0, 0]`
    public var center: [CenterItem]?
    /// Sets the projection’s clipping circle radius to the specified angle in degrees. If `null`, switches to [antimeridian](http://bl.ocks.org/mbostock/3788999) cutting rather than small-circle clipping.
    public var clipAngle: Double?
    /// Sets the projection’s viewport clip extent to the specified bounds in pixels. The extent bounds are specified as an array `[[x0, y0], [x1, y1]]`, where `x0` is the left-side of the viewport, `y0` is the top, `x1` is the right and `y1` is the bottom. If `null`, no viewport clipping is performed.
    public var clipExtent: [ClipExtentItem]?
    public var coefficient: Double?
    public var distance: Double?
    public var fraction: Double?
    public var lobes: Double?
    public var parallel: Double?
    /// Sets the threshold for the projection’s [adaptive resampling](http://bl.ocks.org/mbostock/3795544) to the specified value in pixels. This value corresponds to the [Douglas–Peucker distance](http://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm). If precision is not specified, returns the projection’s current resampling precision which defaults to `√0.5 ≅ 0.70710…`.
    public var precision: Precision?
    public var radius: Double?
    public var ratio: Double?
    /// Sets the projection’s three-axis rotation to the specified angles, which must be a two- or three-element array of numbers [`lambda`, `phi`, `gamma`] specifying the rotation angles in degrees about each spherical axis. (These correspond to yaw, pitch and roll.)
    /// __Default value:__ `[0, 0, 0]`
    public var rotate: [RotateItem]?
    public var spacing: Double?
    public var tilt: Double?
    /// The cartographic projection to use. This value is case-insensitive, for example `"albers"` and `"Albers"` indicate the same projection type. You can find all valid projection types [in the documentation](https://vega.github.io/vega-lite/docs/projection.html#projection-types).
    /// __Default value:__ `mercator`
    public var type: ProjectionType?

    public init(center: [CenterItem]? = .none, clipAngle: Double? = .none, clipExtent: [ClipExtentItem]? = .none, coefficient: Double? = .none, distance: Double? = .none, fraction: Double? = .none, lobes: Double? = .none, parallel: Double? = .none, precision: Precision? = .none, radius: Double? = .none, ratio: Double? = .none, rotate: [RotateItem]? = .none, spacing: Double? = .none, tilt: Double? = .none, type: ProjectionType? = .none) {
        self.center = center 
        self.clipAngle = clipAngle 
        self.clipExtent = clipExtent 
        self.coefficient = coefficient 
        self.distance = distance 
        self.fraction = fraction 
        self.lobes = lobes 
        self.parallel = parallel 
        self.precision = precision 
        self.radius = radius 
        self.ratio = ratio 
        self.rotate = rotate 
        self.spacing = spacing 
        self.tilt = tilt 
        self.type = type 
    }

    public enum CodingKeys : String, CodingKey {
        case center
        case clipAngle
        case clipExtent
        case coefficient
        case distance
        case fraction
        case lobes
        case parallel
        case precision
        case radius
        case ratio
        case rotate
        case spacing
        case tilt
        case type
    }

    public typealias CenterItem = Double

    public typealias ClipExtentItem = [Double]

    /// Sets the threshold for the projection’s [adaptive resampling](http://bl.ocks.org/mbostock/3795544) to the specified value in pixels. This value corresponds to the [Douglas–Peucker distance](http://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm). If precision is not specified, returns the projection’s current resampling precision which defaults to `√0.5 ≅ 0.70710…`.
    public struct Precision : Equatable, Codable {
        /// Returns the length of a String object. 
        public var length: Double
        public var additionalProperties: Dictionary<String, Bric>

        public init(length: Double, additionalProperties: Dictionary<String, Bric> = [:]) {
            self.length = length 
            self.additionalProperties = additionalProperties 
        }

        public enum CodingKeys : String, CodingKey {
            case length
            case additionalProperties = ""
        }
    }

    public typealias RotateItem = Double
}

/// Headers of row / column channels for faceted plots.
public struct Header : Equatable, Codable {
    /// The formatting pattern for labels. This is D3's [number format pattern](https://github.com/d3/d3-format#locale_format) for quantitative fields and D3's [time format pattern](https://github.com/d3/d3-time-format#locale_format) for time field.
    /// See the [format documentation](https://vega.github.io/vega-lite/docs/format.html) for more information.
    /// __Default value:__  derived from [numberFormat](https://vega.github.io/vega-lite/docs/config.html#format) config for quantitative fields and from [timeFormat](https://vega.github.io/vega-lite/docs/config.html#format) config for temporal fields.
    public var format: String?
    /// The rotation angle of the header labels.
    /// __Default value:__ `0`.
    public var labelAngle: Double?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?

    public init(format: String? = .none, labelAngle: Double? = .none, title: Title? = .none) {
        self.format = format 
        self.labelAngle = labelAngle 
        self.title = title 
    }

    public enum CodingKeys : String, CodingKey {
        case format
        case labelAngle
        case title
    }

    /// Headers of row / column channels for faceted plots.
    public typealias Title = OneOf2<String, ExplicitNull>
}

public struct Encoding : Equatable, Codable {
    /// Color of the marks – either fill or stroke color based on  the `filled` property of mark definition.
    /// By default, `color` represents fill color for `"area"`, `"bar"`, `"tick"`,
    /// `"text"`, `"trail"`, `"circle"`, and `"square"` / stroke color for `"line"` and `"point"`.
    /// __Default value:__ If undefined, the default color depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `color` property.
    /// _Note:_
    /// 1) For fine-grained control over both fill and stroke colors of the marks, please use the `fill` and `stroke` channels.  If either `fill` or `stroke` channel is specified, `color` channel will be ignored.
    /// 2) See the scale documentation for more information about customizing [color scheme](https://vega.github.io/vega-lite/docs/scale.html#scheme).
    public var color: ColorChoice?
    /// Additional levels of detail for grouping data in aggregate views and
    /// in line, trail, and area marks without mapping data to a specific visual channel.
    public var detail: DetailChoice?
    /// Fill color of the marks.
    /// __Default value:__ If undefined, the default color depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `color` property.
    /// _Note:_ When using `fill` channel, `color ` channel will be ignored. To customize both fill and stroke, please use `fill` and `stroke` channels (not `fill` and `color`).
    public var fill: FillChoice?
    /// A URL to load upon mouse click.
    public var href: HrefChoice?
    /// A data field to use as a unique key for data binding. When a visualization’s data is updated, the key value will be used to match data elements to existing mark instances. Use a key channel to enable object constancy for transitions over dynamic data.
    public var key: FieldDef?
    /// Latitude position of geographically projected marks.
    public var latitude: FieldDef?
    /// Latitude-2 position for geographically projected ranged `"area"`, `"bar"`, `"rect"`, and  `"rule"`.
    public var latitude2: FieldDef?
    /// Longitude position of geographically projected marks.
    public var longitude: FieldDef?
    /// Longitude-2 position for geographically projected ranged `"area"`, `"bar"`, `"rect"`, and  `"rule"`.
    public var longitude2: FieldDef?
    /// Opacity of the marks – either can be a value or a range.
    /// __Default value:__ If undefined, the default opacity depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `opacity` property.
    public var opacity: OpacityChoice?
    /// Order of the marks.
    /// - For stacked marks, this `order` channel encodes [stack order](https://vega.github.io/vega-lite/docs/stack.html#order).
    /// - For line and trail marks, this `order` channel encodes order of data points in the lines. This can be useful for creating [a connected scatterplot](https://vega.github.io/vega-lite/examples/connected_scatterplot.html).  Setting `order` to `{"value": null}` makes the line marks use the original order in the data sources.
    /// - Otherwise, this `order` channel encodes layer order of the marks.
    /// __Note__: In aggregate plots, `order` field should be `aggregate`d to avoid creating additional aggregation grouping.
    public var order: OrderChoice?
    /// For `point` marks the supported values are
    /// `"circle"` (default), `"square"`, `"cross"`, `"diamond"`, `"triangle-up"`,
    /// or `"triangle-down"`, or else a custom SVG path string.
    /// For `geoshape` marks it should be a field definition of the geojson data
    /// __Default value:__ If undefined, the default shape depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#point-config)'s `shape` property.
    public var shape: ShapeChoice?
    /// Size of the mark.
    /// - For `"point"`, `"square"` and `"circle"`, – the symbol size, or pixel area of the mark.
    /// - For `"bar"` and `"tick"` – the bar and tick's size.
    /// - For `"text"` – the text's font size.
    /// - Size is unsupported for `"line"`, `"area"`, and `"rect"`. (Use `"trail"` instead of line with varying size)
    public var size: SizeChoice?
    /// Stroke color of the marks.
    /// __Default value:__ If undefined, the default color depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `color` property.
    /// _Note:_ When using `stroke` channel, `color ` channel will be ignored. To customize both stroke and fill, please use `stroke` and `fill` channels (not `stroke` and `color`).
    public var stroke: StrokeChoice?
    /// Text of the `text` mark.
    public var text: TextChoice?
    /// The tooltip text to show upon mouse hover.
    public var tooltip: TooltipChoice?
    /// X coordinates of the marks, or width of horizontal `"bar"` and `"area"`.
    public var x: XChoice?
    /// X2 coordinates for ranged `"area"`, `"bar"`, `"rect"`, and  `"rule"`.
    public var x2: X2Choice?
    /// Y coordinates of the marks, or height of vertical `"bar"` and `"area"`.
    public var y: YChoice?
    /// Y2 coordinates for ranged `"area"`, `"bar"`, `"rect"`, and  `"rule"`.
    public var y2: Y2Choice?

    public init(color: ColorChoice? = .none, detail: DetailChoice? = .none, fill: FillChoice? = .none, href: HrefChoice? = .none, key: FieldDef? = .none, latitude: FieldDef? = .none, latitude2: FieldDef? = .none, longitude: FieldDef? = .none, longitude2: FieldDef? = .none, opacity: OpacityChoice? = .none, order: OrderChoice? = .none, shape: ShapeChoice? = .none, size: SizeChoice? = .none, stroke: StrokeChoice? = .none, text: TextChoice? = .none, tooltip: TooltipChoice? = .none, x: XChoice? = .none, x2: X2Choice? = .none, y: YChoice? = .none, y2: Y2Choice? = .none) {
        self.color = color 
        self.detail = detail 
        self.fill = fill 
        self.href = href 
        self.key = key 
        self.latitude = latitude 
        self.latitude2 = latitude2 
        self.longitude = longitude 
        self.longitude2 = longitude2 
        self.opacity = opacity 
        self.order = order 
        self.shape = shape 
        self.size = size 
        self.stroke = stroke 
        self.text = text 
        self.tooltip = tooltip 
        self.x = x 
        self.x2 = x2 
        self.y = y 
        self.y2 = y2 
    }

    public enum CodingKeys : String, CodingKey {
        case color
        case detail
        case fill
        case href
        case key
        case latitude
        case latitude2
        case longitude
        case longitude2
        case opacity
        case order
        case shape
        case size
        case stroke
        case text
        case tooltip
        case x
        case x2
        case y
        case y2
    }

    /// Color of the marks – either fill or stroke color based on  the `filled` property of mark definition.
    /// By default, `color` represents fill color for `"area"`, `"bar"`, `"tick"`,
    /// `"text"`, `"trail"`, `"circle"`, and `"square"` / stroke color for `"line"` and `"point"`.
    /// __Default value:__ If undefined, the default color depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `color` property.
    /// _Note:_
    /// 1) For fine-grained control over both fill and stroke colors of the marks, please use the `fill` and `stroke` channels.  If either `fill` or `stroke` channel is specified, `color` channel will be ignored.
    /// 2) See the scale documentation for more information about customizing [color scheme](https://vega.github.io/vega-lite/docs/scale.html#scheme).
    public typealias ColorChoice = OneOf2<MarkPropFieldDefWithCondition, MarkPropValueDefWithCondition>

    /// Additional levels of detail for grouping data in aggregate views and
    /// in line, trail, and area marks without mapping data to a specific visual channel.
    public typealias DetailChoice = OneOf2<FieldDef, [FieldDef]>

    /// Fill color of the marks.
    /// __Default value:__ If undefined, the default color depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `color` property.
    /// _Note:_ When using `fill` channel, `color ` channel will be ignored. To customize both fill and stroke, please use `fill` and `stroke` channels (not `fill` and `color`).
    public typealias FillChoice = OneOf2<MarkPropFieldDefWithCondition, MarkPropValueDefWithCondition>

    /// A URL to load upon mouse click.
    public typealias HrefChoice = OneOf2<FieldDefWithCondition, ValueDefWithCondition>

    /// Opacity of the marks – either can be a value or a range.
    /// __Default value:__ If undefined, the default opacity depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `opacity` property.
    public typealias OpacityChoice = OneOf2<MarkPropFieldDefWithCondition, MarkPropValueDefWithCondition>

    /// Order of the marks.
    /// - For stacked marks, this `order` channel encodes [stack order](https://vega.github.io/vega-lite/docs/stack.html#order).
    /// - For line and trail marks, this `order` channel encodes order of data points in the lines. This can be useful for creating [a connected scatterplot](https://vega.github.io/vega-lite/examples/connected_scatterplot.html).  Setting `order` to `{"value": null}` makes the line marks use the original order in the data sources.
    /// - Otherwise, this `order` channel encodes layer order of the marks.
    /// __Note__: In aggregate plots, `order` field should be `aggregate`d to avoid creating additional aggregation grouping.
    public typealias OrderChoice = OneOf3<OrderFieldDef, [OrderFieldDef], ValueDef>

    /// For `point` marks the supported values are
    /// `"circle"` (default), `"square"`, `"cross"`, `"diamond"`, `"triangle-up"`,
    /// or `"triangle-down"`, or else a custom SVG path string.
    /// For `geoshape` marks it should be a field definition of the geojson data
    /// __Default value:__ If undefined, the default shape depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#point-config)'s `shape` property.
    public typealias ShapeChoice = OneOf2<MarkPropFieldDefWithCondition, MarkPropValueDefWithCondition>

    /// Size of the mark.
    /// - For `"point"`, `"square"` and `"circle"`, – the symbol size, or pixel area of the mark.
    /// - For `"bar"` and `"tick"` – the bar and tick's size.
    /// - For `"text"` – the text's font size.
    /// - Size is unsupported for `"line"`, `"area"`, and `"rect"`. (Use `"trail"` instead of line with varying size)
    public typealias SizeChoice = OneOf2<MarkPropFieldDefWithCondition, MarkPropValueDefWithCondition>

    /// Stroke color of the marks.
    /// __Default value:__ If undefined, the default color depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `color` property.
    /// _Note:_ When using `stroke` channel, `color ` channel will be ignored. To customize both stroke and fill, please use `stroke` and `fill` channels (not `stroke` and `color`).
    public typealias StrokeChoice = OneOf2<MarkPropFieldDefWithCondition, MarkPropValueDefWithCondition>

    /// Text of the `text` mark.
    public typealias TextChoice = OneOf2<TextFieldDefWithCondition, TextValueDefWithCondition>

    /// The tooltip text to show upon mouse hover.
    public typealias TooltipChoice = OneOf3<TextFieldDefWithCondition, TextValueDefWithCondition, [TextFieldDef]>

    /// X coordinates of the marks, or width of horizontal `"bar"` and `"area"`.
    public typealias XChoice = OneOf2<PositionFieldDef, ValueDef>

    /// X2 coordinates for ranged `"area"`, `"bar"`, `"rect"`, and  `"rule"`.
    public typealias X2Choice = OneOf2<FieldDef, ValueDef>

    /// Y coordinates of the marks, or height of vertical `"bar"` and `"area"`.
    public typealias YChoice = OneOf2<PositionFieldDef, ValueDef>

    /// Y2 coordinates for ranged `"area"`, `"bar"`, `"rect"`, and  `"rule"`.
    public typealias Y2Choice = OneOf2<FieldDef, ValueDef>
}

public struct UrlData : Equatable, Codable {
    /// An URL from which to load the data set. Use the `format.type` property
    /// to ensure the loaded data is correctly parsed.
    public var url: String
    /// An object that specifies the format for parsing the data.
    public var format: DataFormat?
    /// Provide a placeholder name and bind data at runtime.
    public var name: String?

    public init(url: String, format: DataFormat? = .none, name: String? = .none) {
        self.url = url 
        self.format = format 
        self.name = name 
    }

    public enum CodingKeys : String, CodingKey {
        case url
        case format
        case name
    }
}

public struct FacetFieldDef : Equatable, Codable {
    /// The encoded field's type of measurement (`"quantitative"`, `"temporal"`, `"ordinal"`, or `"nominal"`).
    /// It can also be a `"geojson"` type for encoding ['geoshape'](https://vega.github.io/vega-lite/docs/geoshape.html).
    public var type: `Type`
    /// Aggregation function for the field
    /// (e.g., `mean`, `sum`, `median`, `min`, `max`, `count`).
    /// __Default value:__ `undefined` (None)
    public var aggregate: Aggregate?
    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public var bin: BinChoice?
    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public var field: FieldChoice?
    /// An object defining properties of a facet's header.
    public var header: Header?
    /// Sort order for a facet field.
    /// This can be `"ascending"`, `"descending"`.
    public var sort: SortOrder?
    /// Time unit (e.g., `year`, `yearmonth`, `month`, `hours`) for a temporal field.
    /// or [a temporal field that gets casted as ordinal](https://vega.github.io/vega-lite/docs/type.html#cast).
    /// __Default value:__ `undefined` (None)
    public var timeUnit: TimeUnit?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?

    public init(type: `Type`, aggregate: Aggregate? = .none, bin: BinChoice? = .none, field: FieldChoice? = .none, header: Header? = .none, sort: SortOrder? = .none, timeUnit: TimeUnit? = .none, title: Title? = .none) {
        self.type = type 
        self.aggregate = aggregate 
        self.bin = bin 
        self.field = field 
        self.header = header 
        self.sort = sort 
        self.timeUnit = timeUnit 
        self.title = title 
    }

    public enum CodingKeys : String, CodingKey {
        case type
        case aggregate
        case bin
        case field
        case header
        case sort
        case timeUnit
        case title
    }

    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public typealias BinChoice = OneOf2<Bool, BinParams>

    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public typealias FieldChoice = OneOf2<String, RepeatRef>

    public typealias Title = OneOf2<String, ExplicitNull>
}

public struct LogicalNotPredicate : Equatable, Codable {
    public var not: LogicalOperandPredicate

    public init(not: LogicalOperandPredicate) {
        self.not = not 
    }

    public enum CodingKeys : String, CodingKey {
        case not
    }
}

public struct PositionFieldDef : Equatable, Codable {
    /// The encoded field's type of measurement (`"quantitative"`, `"temporal"`, `"ordinal"`, or `"nominal"`).
    /// It can also be a `"geojson"` type for encoding ['geoshape'](https://vega.github.io/vega-lite/docs/geoshape.html).
    public var type: `Type`
    /// Aggregation function for the field
    /// (e.g., `mean`, `sum`, `median`, `min`, `max`, `count`).
    /// __Default value:__ `undefined` (None)
    public var aggregate: Aggregate?
    /// An object defining properties of axis's gridlines, ticks and labels.
    /// If `null`, the axis for the encoding channel will be removed.
    /// __Default value:__ If undefined, default [axis properties](https://vega.github.io/vega-lite/docs/axis.html) are applied.
    public var axis: AxisChoice?
    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public var bin: BinChoice?
    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public var field: FieldChoice?
    /// An object defining properties of the channel's scale, which is the function that transforms values in the data domain (numbers, dates, strings, etc) to visual values (pixels, colors, sizes) of the encoding channels.
    /// If `null`, the scale will be [disabled and the data value will be directly encoded](https://vega.github.io/vega-lite/docs/scale.html#disable).
    /// __Default value:__ If undefined, default [scale properties](https://vega.github.io/vega-lite/docs/scale.html) are applied.
    public var scale: ScaleChoice?
    /// Sort order for the encoded field.
    /// Supported `sort` values include `"ascending"`, `"descending"`, `null` (no sorting), or an array specifying the preferred order of values.
    /// For fields with discrete domains, `sort` can also be a [sort field definition object](https://vega.github.io/vega-lite/docs/sort.html#sort-field).
    /// For `sort` as an [array specifying the preferred order of values](https://vega.github.io/vega-lite/docs/sort.html#sort-array), the sort order will obey the values in the array, followed by any unspecified values in their original order.
    /// __Default value:__ `"ascending"`
    public var sort: SortChoice?
    /// Type of stacking offset if the field should be stacked.
    /// `stack` is only applicable for `x` and `y` channels with continuous domains.
    /// For example, `stack` of `y` can be used to customize stacking for a vertical bar chart.
    /// `stack` can be one of the following values:
    /// - `"zero"`: stacking with baseline offset at zero value of the scale (for creating typical stacked [bar](https://vega.github.io/vega-lite/docs/stack.html#bar) and [area](https://vega.github.io/vega-lite/docs/stack.html#area) chart).
    /// - `"normalize"` - stacking with normalized domain (for creating [normalized stacked bar and area charts](https://vega.github.io/vega-lite/docs/stack.html#normalized). <br/>
    /// -`"center"` - stacking with center baseline (for [streamgraph](https://vega.github.io/vega-lite/docs/stack.html#streamgraph)).
    /// - `null` - No-stacking. This will produce layered [bar](https://vega.github.io/vega-lite/docs/stack.html#layered-bar-chart) and area chart.
    /// __Default value:__ `zero` for plots with all of the following conditions are true:
    /// (1) the mark is `bar` or `area`;
    /// (2) the stacked measure channel (x or y) has a linear scale;
    /// (3) At least one of non-position channels mapped to an unaggregated field that is different from x and y.  Otherwise, `null` by default.
    public var stack: StackChoice?
    /// Time unit (e.g., `year`, `yearmonth`, `month`, `hours`) for a temporal field.
    /// or [a temporal field that gets casted as ordinal](https://vega.github.io/vega-lite/docs/type.html#cast).
    /// __Default value:__ `undefined` (None)
    public var timeUnit: TimeUnit?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?

    public init(type: `Type`, aggregate: Aggregate? = .none, axis: AxisChoice? = .none, bin: BinChoice? = .none, field: FieldChoice? = .none, scale: ScaleChoice? = .none, sort: SortChoice? = .none, stack: StackChoice? = .none, timeUnit: TimeUnit? = .none, title: Title? = .none) {
        self.type = type 
        self.aggregate = aggregate 
        self.axis = axis 
        self.bin = bin 
        self.field = field 
        self.scale = scale 
        self.sort = sort 
        self.stack = stack 
        self.timeUnit = timeUnit 
        self.title = title 
    }

    public enum CodingKeys : String, CodingKey {
        case type
        case aggregate
        case axis
        case bin
        case field
        case scale
        case sort
        case stack
        case timeUnit
        case title
    }

    /// An object defining properties of axis's gridlines, ticks and labels.
    /// If `null`, the axis for the encoding channel will be removed.
    /// __Default value:__ If undefined, default [axis properties](https://vega.github.io/vega-lite/docs/axis.html) are applied.
    public typealias AxisChoice = OneOf2<Axis, ExplicitNull>

    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public typealias BinChoice = OneOf2<Bool, BinParams>

    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public typealias FieldChoice = OneOf2<String, RepeatRef>

    /// An object defining properties of the channel's scale, which is the function that transforms values in the data domain (numbers, dates, strings, etc) to visual values (pixels, colors, sizes) of the encoding channels.
    /// If `null`, the scale will be [disabled and the data value will be directly encoded](https://vega.github.io/vega-lite/docs/scale.html#disable).
    /// __Default value:__ If undefined, default [scale properties](https://vega.github.io/vega-lite/docs/scale.html) are applied.
    public typealias ScaleChoice = OneOf2<Scale, ExplicitNull>

    /// Sort order for the encoded field.
    /// Supported `sort` values include `"ascending"`, `"descending"`, `null` (no sorting), or an array specifying the preferred order of values.
    /// For fields with discrete domains, `sort` can also be a [sort field definition object](https://vega.github.io/vega-lite/docs/sort.html#sort-field).
    /// For `sort` as an [array specifying the preferred order of values](https://vega.github.io/vega-lite/docs/sort.html#sort-array), the sort order will obey the values in the array, followed by any unspecified values in their original order.
    /// __Default value:__ `"ascending"`
    public typealias SortChoice = OneOf4<[String], SortOrder, EncodingSortField, ExplicitNull>

    /// Type of stacking offset if the field should be stacked.
    /// `stack` is only applicable for `x` and `y` channels with continuous domains.
    /// For example, `stack` of `y` can be used to customize stacking for a vertical bar chart.
    /// `stack` can be one of the following values:
    /// - `"zero"`: stacking with baseline offset at zero value of the scale (for creating typical stacked [bar](https://vega.github.io/vega-lite/docs/stack.html#bar) and [area](https://vega.github.io/vega-lite/docs/stack.html#area) chart).
    /// - `"normalize"` - stacking with normalized domain (for creating [normalized stacked bar and area charts](https://vega.github.io/vega-lite/docs/stack.html#normalized). <br/>
    /// -`"center"` - stacking with center baseline (for [streamgraph](https://vega.github.io/vega-lite/docs/stack.html#streamgraph)).
    /// - `null` - No-stacking. This will produce layered [bar](https://vega.github.io/vega-lite/docs/stack.html#layered-bar-chart) and area chart.
    /// __Default value:__ `zero` for plots with all of the following conditions are true:
    /// (1) the mark is `bar` or `area`;
    /// (2) the stacked measure channel (x or y) has a linear scale;
    /// (3) At least one of non-position channels mapped to an unaggregated field that is different from x and y.  Otherwise, `null` by default.
    public typealias StackChoice = OneOf2<StackOffset, ExplicitNull>

    public typealias Title = OneOf2<String, ExplicitNull>
}

public struct VgScheme : Equatable, Codable {
    public var scheme: String
    public var count: Double?
    public var extent: [ExtentItem]?

    public init(scheme: String, count: Double? = .none, extent: [ExtentItem]? = .none) {
        self.scheme = scheme 
        self.count = count 
        self.extent = extent 
    }

    public enum CodingKeys : String, CodingKey {
        case scheme
        case count
        case extent
    }

    public typealias ExtentItem = Double
}

public typealias FontWeight = OneOf2<FontWeightString, FontWeightNumber>

/// Layer Spec with encoding and projection
public struct LayerSpec : Equatable, Codable {
    /// Layer or single view specifications to be layered.
    /// __Note__: Specifications inside `layer` cannot use `row` and `column` channels as layering facet specifications is not allowed.
    public var layer: [LayerItemChoice]
    /// An object describing the data source
    public var data: Data?
    /// Description of this mark for commenting purpose.
    public var description: String?
    /// A shared key-value mapping between encoding channels and definition of fields in the underlying layers.
    public var encoding: Encoding?
    /// The height of a visualization.
    /// __Default value:__
    /// - If a view's [`autosize`](https://vega.github.io/vega-lite/docs/size.html#autosize) type is `"fit"` or its y-channel has a [continuous scale](https://vega.github.io/vega-lite/docs/scale.html#continuous), the height will be the value of [`config.view.height`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - For y-axis with a band or point scale: if [`rangeStep`](https://vega.github.io/vega-lite/docs/scale.html#band) is a numeric value or unspecified, the height is [determined by the range step, paddings, and the cardinality of the field mapped to y-channel](https://vega.github.io/vega-lite/docs/scale.html#band). Otherwise, if the `rangeStep` is `null`, the height will be the value of [`config.view.height`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - If no field is mapped to `y` channel, the `height` will be the value of `rangeStep`.
    /// __Note__: For plots with [`row` and `column` channels](https://vega.github.io/vega-lite/docs/encoding.html#facet), this represents the height of a single view.
    /// __See also:__ The documentation for [width and height](https://vega.github.io/vega-lite/docs/size.html) contains more examples.
    public var height: Double?
    /// Name of the visualization for later reference.
    public var name: String?
    /// An object defining properties of the geographic projection shared by underlying layers.
    public var projection: Projection?
    /// Scale, axis, and legend resolutions for layers.
    public var resolve: Resolve?
    /// Title for the plot.
    public var title: TitleChoice?
    /// An array of data transformations such as filter and new field calculation.
    public var transform: [Transform]?
    /// The width of a visualization.
    /// __Default value:__ This will be determined by the following rules:
    /// - If a view's [`autosize`](https://vega.github.io/vega-lite/docs/size.html#autosize) type is `"fit"` or its x-channel has a [continuous scale](https://vega.github.io/vega-lite/docs/scale.html#continuous), the width will be the value of [`config.view.width`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - For x-axis with a band or point scale: if [`rangeStep`](https://vega.github.io/vega-lite/docs/scale.html#band) is a numeric value or unspecified, the width is [determined by the range step, paddings, and the cardinality of the field mapped to x-channel](https://vega.github.io/vega-lite/docs/scale.html#band).   Otherwise, if the `rangeStep` is `null`, the width will be the value of [`config.view.width`](https://vega.github.io/vega-lite/docs/spec.html#config).
    /// - If no field is mapped to `x` channel, the `width` will be the value of [`config.scale.textXRangeStep`](https://vega.github.io/vega-lite/docs/size.html#default-width-and-height) for `text` mark and the value of `rangeStep` for other marks.
    /// __Note:__ For plots with [`row` and `column` channels](https://vega.github.io/vega-lite/docs/encoding.html#facet), this represents the width of a single view.
    /// __See also:__ The documentation for [width and height](https://vega.github.io/vega-lite/docs/size.html) contains more examples.
    public var width: Double?

    public init(layer: [LayerItemChoice] = [], data: Data? = .none, description: String? = .none, encoding: Encoding? = .none, height: Double? = .none, name: String? = .none, projection: Projection? = .none, resolve: Resolve? = .none, title: TitleChoice? = .none, transform: [Transform]? = .none, width: Double? = .none) {
        self.layer = layer 
        self.data = data 
        self.description = description 
        self.encoding = encoding 
        self.height = height 
        self.name = name 
        self.projection = projection 
        self.resolve = resolve 
        self.title = title 
        self.transform = transform 
        self.width = width 
    }

    public enum CodingKeys : String, CodingKey {
        case layer
        case data
        case description
        case encoding
        case height
        case name
        case projection
        case resolve
        case title
        case transform
        case width
    }

    public typealias LayerItemChoice = OneOf2<LayerSpec, CompositeUnitSpec>

    /// Title for the plot.
    public typealias TitleChoice = OneOf2<String, TitleParams>
}

public enum UtcSingleTimeUnit : String, Equatable, Codable {
    case utcyear
    case utcquarter
    case utcmonth
    case utcday
    case utcdate
    case utchours
    case utcminutes
    case utcseconds
    case utcmilliseconds
}

public struct TopoDataFormat : Equatable, Codable {
    /// The name of the TopoJSON object set to convert to a GeoJSON feature collection.
    /// For example, in a map of the world, there may be an object set named `"countries"`.
    /// Using the feature property, we can extract this set and generate a GeoJSON feature object for each country.
    public var feature: String?
    /// The name of the TopoJSON object set to convert to mesh.
    /// Similar to the `feature` option, `mesh` extracts a named TopoJSON object set.
    ///   Unlike the `feature` option, the corresponding geo data is returned as a single, unified mesh instance, not as individual GeoJSON features.
    /// Extracting a mesh is useful for more efficiently drawing borders or other geographic elements that you do not need to associate with specific regions such as individual countries, states or counties.
    public var mesh: String?
    /// If set to `"auto"` (the default), perform automatic type inference to determine the desired data types.
    /// If set to `null`, disable type inference based on the spec and only use type inference based on the data.
    /// Alternatively, a parsing directive object can be provided for explicit data types. Each property of the object corresponds to a field name, and the value to the desired data type (one of `"number"`, `"boolean"`, `"date"`, or null (do not parse the field)).
    /// For example, `"parse": {"modified_on": "date"}` parses the `modified_on` field in each input record a Date value.
    /// For `"date"`, we parse data based using Javascript's [`Date.parse()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse).
    /// For Specific date formats can be provided (e.g., `{foo: 'date:"%m%d%Y"'}`), using the [d3-time-format syntax](https://github.com/d3/d3-time-format#locale_format). UTC date format parsing is supported similarly (e.g., `{foo: 'utc:"%m%d%Y"'}`). See more about [UTC time](https://vega.github.io/vega-lite/docs/timeunit.html#utc)
    public var parse: ParseChoice?
    /// Type of input data: `"json"`, `"csv"`, `"tsv"`, `"dsv"`.
    /// The default format type is determined by the extension of the file URL.
    /// If no extension is detected, `"json"` will be used by default.
    public var type: `Type`?

    public init(feature: String? = .none, mesh: String? = .none, parse: ParseChoice? = .none, type: `Type`? = .none) {
        self.feature = feature 
        self.mesh = mesh 
        self.parse = parse 
        self.type = type 
    }

    public enum CodingKeys : String, CodingKey {
        case feature
        case mesh
        case parse
        case type
    }

    /// If set to `"auto"` (the default), perform automatic type inference to determine the desired data types.
    /// If set to `null`, disable type inference based on the spec and only use type inference based on the data.
    /// Alternatively, a parsing directive object can be provided for explicit data types. Each property of the object corresponds to a field name, and the value to the desired data type (one of `"number"`, `"boolean"`, `"date"`, or null (do not parse the field)).
    /// For example, `"parse": {"modified_on": "date"}` parses the `modified_on` field in each input record a Date value.
    /// For `"date"`, we parse data based using Javascript's [`Date.parse()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse).
    /// For Specific date formats can be provided (e.g., `{foo: 'date:"%m%d%Y"'}`), using the [d3-time-format syntax](https://github.com/d3/d3-time-format#locale_format). UTC date format parsing is supported similarly (e.g., `{foo: 'utc:"%m%d%Y"'}`). See more about [UTC time](https://vega.github.io/vega-lite/docs/timeunit.html#utc)
    public typealias ParseChoice = ParseTypes.Choice
    public enum ParseTypes {

        public typealias Choice = OneOf3<Type1, Parse, ExplicitNull>

        public enum Type1 : String, Equatable, Codable {
            case auto
        }
    }

    /// Type of input data: `"json"`, `"csv"`, `"tsv"`, `"dsv"`.
    /// The default format type is determined by the extension of the file URL.
    /// If no extension is detected, `"json"` will be used by default.
    public enum `Type` : String, Equatable, Codable {
        case topojson
    }
}

public typealias SelectionDef = OneOf3<SingleSelection, MultiSelection, IntervalSelection>

public struct ConditionalSelectionTextFieldDef : Equatable, Codable {
    /// A [selection name](https://vega.github.io/vega-lite/docs/selection.html), or a series of [composed selections](https://vega.github.io/vega-lite/docs/selection.html#compose).
    public var selection: SelectionOperand
    /// The encoded field's type of measurement (`"quantitative"`, `"temporal"`, `"ordinal"`, or `"nominal"`).
    /// It can also be a `"geojson"` type for encoding ['geoshape'](https://vega.github.io/vega-lite/docs/geoshape.html).
    public var type: `Type`
    /// Aggregation function for the field
    /// (e.g., `mean`, `sum`, `median`, `min`, `max`, `count`).
    /// __Default value:__ `undefined` (None)
    public var aggregate: Aggregate?
    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public var bin: BinChoice?
    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public var field: FieldChoice?
    /// The [formatting pattern](https://vega.github.io/vega-lite/docs/format.html) for a text field. If not defined, this will be determined automatically.
    public var format: String?
    /// Time unit (e.g., `year`, `yearmonth`, `month`, `hours`) for a temporal field.
    /// or [a temporal field that gets casted as ordinal](https://vega.github.io/vega-lite/docs/type.html#cast).
    /// __Default value:__ `undefined` (None)
    public var timeUnit: TimeUnit?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?

    public init(selection: SelectionOperand, type: `Type`, aggregate: Aggregate? = .none, bin: BinChoice? = .none, field: FieldChoice? = .none, format: String? = .none, timeUnit: TimeUnit? = .none, title: Title? = .none) {
        self.selection = selection 
        self.type = type 
        self.aggregate = aggregate 
        self.bin = bin 
        self.field = field 
        self.format = format 
        self.timeUnit = timeUnit 
        self.title = title 
    }

    public enum CodingKeys : String, CodingKey {
        case selection
        case type
        case aggregate
        case bin
        case field
        case format
        case timeUnit
        case title
    }

    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public typealias BinChoice = OneOf2<Bool, BinParams>

    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public typealias FieldChoice = OneOf2<String, RepeatRef>

    public typealias Title = OneOf2<String, ExplicitNull>
}

public struct VgCheckboxBinding : Equatable, Codable {
    public var input: Input
    public var element: String?

    public init(input: Input = .checkbox, element: String? = .none) {
        self.input = input 
        self.element = element 
    }

    public enum CodingKeys : String, CodingKey {
        case input
        case element
    }

    public enum Input : String, Equatable, Codable {
        case checkbox
    }
}

public struct TopLevelFacetSpec : Equatable, Codable {
    /// An object describing the data source
    public var data: Data
    /// An object that describes mappings between `row` and `column` channels and their field definitions.
    public var facet: FacetMapping
    /// A specification of the view that gets faceted.
    public var spec: SpecChoice
    /// URL to [JSON schema](http://json-schema.org/) for a Vega-Lite specification. Unless you have a reason to change this, use `https://vega.github.io/schema/vega-lite/v2.json`. Setting the `$schema` property allows automatic validation and autocomplete in editors that support JSON schema.
    public var schema: String?
    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public var autosize: AutosizeChoice?
    /// CSS color property to use as the background of visualization.
    /// __Default value:__ none (transparent)
    public var background: String?
    /// Vega-Lite configuration object.  This property can only be defined at the top-level of a specification.
    public var config: Config?
    /// A global data store for named datasets. This is a mapping from names to inline datasets.
    /// This can be an array of objects or primitive values or a string. Arrays of primitive values are ingested as objects with a `data` property.
    public var datasets: Datasets?
    /// Description of this mark for commenting purpose.
    public var description: String?
    /// Name of the visualization for later reference.
    public var name: String?
    /// The default visualization padding, in pixels, from the edge of the visualization canvas to the data rectangle.  If a number, specifies padding for all sides.
    /// If an object, the value should have the format `{"left": 5, "top": 5, "right": 5, "bottom": 5}` to specify padding for each side of the visualization.
    /// __Default value__: `5`
    public var padding: Padding?
    /// Scale, axis, and legend resolutions for facets.
    public var resolve: Resolve?
    /// Title for the plot.
    public var title: TitleChoice?
    /// An array of data transformations such as filter and new field calculation.
    public var transform: [Transform]?

    public init(data: Data, facet: FacetMapping, spec: SpecChoice, schema: String? = .none, autosize: AutosizeChoice? = .none, background: String? = .none, config: Config? = .none, datasets: Datasets? = .none, description: String? = .none, name: String? = .none, padding: Padding? = .none, resolve: Resolve? = .none, title: TitleChoice? = .none, transform: [Transform]? = .none) {
        self.data = data 
        self.facet = facet 
        self.spec = spec 
        self.schema = schema 
        self.autosize = autosize 
        self.background = background 
        self.config = config 
        self.datasets = datasets 
        self.description = description 
        self.name = name 
        self.padding = padding 
        self.resolve = resolve 
        self.title = title 
        self.transform = transform 
    }

    public enum CodingKeys : String, CodingKey {
        case data
        case facet
        case spec
        case schema = "$schema"
        case autosize
        case background
        case config
        case datasets
        case description
        case name
        case padding
        case resolve
        case title
        case transform
    }

    /// A specification of the view that gets faceted.
    public typealias SpecChoice = OneOf2<LayerSpec, CompositeUnitSpec>

    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public typealias AutosizeChoice = OneOf2<AutosizeType, AutoSizeParams>

    /// Title for the plot.
    public typealias TitleChoice = OneOf2<String, TitleParams>
}

public struct ConditionalSelectionMarkPropFieldDef : Equatable, Codable {
    /// A [selection name](https://vega.github.io/vega-lite/docs/selection.html), or a series of [composed selections](https://vega.github.io/vega-lite/docs/selection.html#compose).
    public var selection: SelectionOperand
    /// The encoded field's type of measurement (`"quantitative"`, `"temporal"`, `"ordinal"`, or `"nominal"`).
    /// It can also be a `"geojson"` type for encoding ['geoshape'](https://vega.github.io/vega-lite/docs/geoshape.html).
    public var type: `Type`
    /// Aggregation function for the field
    /// (e.g., `mean`, `sum`, `median`, `min`, `max`, `count`).
    /// __Default value:__ `undefined` (None)
    public var aggregate: Aggregate?
    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public var bin: BinChoice?
    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public var field: FieldChoice?
    /// An object defining properties of the legend.
    /// If `null`, the legend for the encoding channel will be removed.
    /// __Default value:__ If undefined, default [legend properties](https://vega.github.io/vega-lite/docs/legend.html) are applied.
    public var legend: LegendChoice?
    /// An object defining properties of the channel's scale, which is the function that transforms values in the data domain (numbers, dates, strings, etc) to visual values (pixels, colors, sizes) of the encoding channels.
    /// If `null`, the scale will be [disabled and the data value will be directly encoded](https://vega.github.io/vega-lite/docs/scale.html#disable).
    /// __Default value:__ If undefined, default [scale properties](https://vega.github.io/vega-lite/docs/scale.html) are applied.
    public var scale: ScaleChoice?
    /// Sort order for the encoded field.
    /// Supported `sort` values include `"ascending"`, `"descending"`, `null` (no sorting), or an array specifying the preferred order of values.
    /// For fields with discrete domains, `sort` can also be a [sort field definition object](https://vega.github.io/vega-lite/docs/sort.html#sort-field).
    /// For `sort` as an [array specifying the preferred order of values](https://vega.github.io/vega-lite/docs/sort.html#sort-array), the sort order will obey the values in the array, followed by any unspecified values in their original order.
    /// __Default value:__ `"ascending"`
    public var sort: SortChoice?
    /// Time unit (e.g., `year`, `yearmonth`, `month`, `hours`) for a temporal field.
    /// or [a temporal field that gets casted as ordinal](https://vega.github.io/vega-lite/docs/type.html#cast).
    /// __Default value:__ `undefined` (None)
    public var timeUnit: TimeUnit?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?

    public init(selection: SelectionOperand, type: `Type`, aggregate: Aggregate? = .none, bin: BinChoice? = .none, field: FieldChoice? = .none, legend: LegendChoice? = .none, scale: ScaleChoice? = .none, sort: SortChoice? = .none, timeUnit: TimeUnit? = .none, title: Title? = .none) {
        self.selection = selection 
        self.type = type 
        self.aggregate = aggregate 
        self.bin = bin 
        self.field = field 
        self.legend = legend 
        self.scale = scale 
        self.sort = sort 
        self.timeUnit = timeUnit 
        self.title = title 
    }

    public enum CodingKeys : String, CodingKey {
        case selection
        case type
        case aggregate
        case bin
        case field
        case legend
        case scale
        case sort
        case timeUnit
        case title
    }

    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public typealias BinChoice = OneOf2<Bool, BinParams>

    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public typealias FieldChoice = OneOf2<String, RepeatRef>

    /// An object defining properties of the legend.
    /// If `null`, the legend for the encoding channel will be removed.
    /// __Default value:__ If undefined, default [legend properties](https://vega.github.io/vega-lite/docs/legend.html) are applied.
    public typealias LegendChoice = OneOf2<Legend, ExplicitNull>

    /// An object defining properties of the channel's scale, which is the function that transforms values in the data domain (numbers, dates, strings, etc) to visual values (pixels, colors, sizes) of the encoding channels.
    /// If `null`, the scale will be [disabled and the data value will be directly encoded](https://vega.github.io/vega-lite/docs/scale.html#disable).
    /// __Default value:__ If undefined, default [scale properties](https://vega.github.io/vega-lite/docs/scale.html) are applied.
    public typealias ScaleChoice = OneOf2<Scale, ExplicitNull>

    /// Sort order for the encoded field.
    /// Supported `sort` values include `"ascending"`, `"descending"`, `null` (no sorting), or an array specifying the preferred order of values.
    /// For fields with discrete domains, `sort` can also be a [sort field definition object](https://vega.github.io/vega-lite/docs/sort.html#sort-field).
    /// For `sort` as an [array specifying the preferred order of values](https://vega.github.io/vega-lite/docs/sort.html#sort-array), the sort order will obey the values in the array, followed by any unspecified values in their original order.
    /// __Default value:__ `"ascending"`
    public typealias SortChoice = OneOf4<[String], SortOrder, EncodingSortField, ExplicitNull>

    public typealias Title = OneOf2<String, ExplicitNull>
}

public struct Scale : Equatable, Codable {
    /// The logarithm base of the `log` scale (default `10`).
    public var base: Double?
    /// If `true`, values that exceed the data domain are clamped to either the minimum or maximum range value
    /// __Default value:__ derived from the [scale config](https://vega.github.io/vega-lite/docs/config.html#scale-config)'s `clamp` (`true` by default).
    public var clamp: Bool?
    /// Customized domain values.
    /// For _quantitative_ fields, `domain` can take the form of a two-element array with minimum and maximum values.  [Piecewise scales](https://vega.github.io/vega-lite/docs/scale.html#piecewise) can be created by providing a `domain` with more than two entries.
    /// If the input field is aggregated, `domain` can also be a string value `"unaggregated"`, indicating that the domain should include the raw data values prior to the aggregation.
    /// For _temporal_ fields, `domain` can be a two-element array minimum and maximum values, in the form of either timestamps or the [DateTime definition objects](https://vega.github.io/vega-lite/docs/types.html#datetime).
    /// For _ordinal_ and _nominal_ fields, `domain` can be an array that lists valid input values.
    /// The `selection` property can be used to [interactively determine](https://vega.github.io/vega-lite/docs/selection.html#scale-domains) the scale domain.
    public var domain: DomainChoice?
    /// The exponent of the `pow` scale.
    public var exponent: Double?
    /// The interpolation method for range values. By default, a general interpolator for numbers, dates, strings and colors (in RGB space) is used. For color ranges, this property allows interpolation in alternative color spaces. Legal values include `rgb`, `hsl`, `hsl-long`, `lab`, `hcl`, `hcl-long`, `cubehelix` and `cubehelix-long` ('-long' variants use longer paths in polar coordinate spaces). If object-valued, this property accepts an object with a string-valued _type_ property and an optional numeric _gamma_ property applicable to rgb and cubehelix interpolators. For more, see the [d3-interpolate documentation](https://github.com/d3/d3-interpolate).
    /// __Note:__ Sequential scales do not support `interpolate` as they have a fixed interpolator.  Since Vega-Lite uses sequential scales for quantitative fields by default, you have to set the scale `type` to other quantitative scale type such as `"linear"` to customize `interpolate`.
    public var interpolate: InterpolateChoice?
    /// Extending the domain so that it starts and ends on nice round values. This method typically modifies the scale’s domain, and may only extend the bounds to the nearest round value. Nicing is useful if the domain is computed from data and may be irregular. For example, for a domain of _[0.201479…, 0.996679…]_, a nice domain might be _[0.2, 1.0]_.
    /// For quantitative scales such as linear, `nice` can be either a boolean flag or a number. If `nice` is a number, it will represent a desired tick count. This allows greater control over the step size used to extend the bounds, guaranteeing that the returned ticks will exactly cover the domain.
    /// For temporal fields with time and utc scales, the `nice` value can be a string indicating the desired time interval. Legal values are `"millisecond"`, `"second"`, `"minute"`, `"hour"`, `"day"`, `"week"`, `"month"`, and `"year"`. Alternatively, `time` and `utc` scales can accept an object-valued interval specifier of the form `{"interval": "month", "step": 3}`, which includes a desired number of interval steps. Here, the domain would snap to quarter (Jan, Apr, Jul, Oct) boundaries.
    /// __Default value:__ `true` for unbinned _quantitative_ fields; `false` otherwise.
    public var nice: NiceChoice?
    /// For _[continuous](https://vega.github.io/vega-lite/docs/scale.html#continuous)_ scales, expands the scale domain to accommodate the specified number of pixels on each of the scale range. The scale range must represent pixels for this parameter to function as intended. Padding adjustment is performed prior to all other adjustments, including the effects of the zero, nice, domainMin, and domainMax properties.
    /// For _[band](https://vega.github.io/vega-lite/docs/scale.html#band)_ scales, shortcut for setting `paddingInner` and `paddingOuter` to the same value.
    /// For _[point](https://vega.github.io/vega-lite/docs/scale.html#point)_ scales, alias for `paddingOuter`.
    /// __Default value:__ For _continuous_ scales, derived from the [scale config](https://vega.github.io/vega-lite/docs/scale.html#config)'s `continuousPadding`.
    /// For _band and point_ scales, see `paddingInner` and `paddingOuter`.
    public var padding: Double?
    /// The inner padding (spacing) within each band step of band scales, as a fraction of the step size. This value must lie in the range [0,1].
    /// For point scale, this property is invalid as point scales do not have internal band widths (only step sizes between bands).
    /// __Default value:__ derived from the [scale config](https://vega.github.io/vega-lite/docs/scale.html#config)'s `bandPaddingInner`.
    public var paddingInner: Double?
    /// The outer padding (spacing) at the ends of the range of band and point scales,
    /// as a fraction of the step size. This value must lie in the range [0,1].
    /// __Default value:__ derived from the [scale config](https://vega.github.io/vega-lite/docs/scale.html#config)'s `bandPaddingOuter` for band scales and `pointPadding` for point scales.
    public var paddingOuter: Double?
    /// The range of the scale. One of:
    /// - A string indicating a [pre-defined named scale range](https://vega.github.io/vega-lite/docs/scale.html#range-config) (e.g., example, `"symbol"`, or `"diverging"`).
    /// - For [continuous scales](https://vega.github.io/vega-lite/docs/scale.html#continuous), two-element array indicating  minimum and maximum values, or an array with more than two entries for specifying a [piecewise scale](https://vega.github.io/vega-lite/docs/scale.html#piecewise).
    /// - For [discrete](https://vega.github.io/vega-lite/docs/scale.html#discrete) and [discretizing](https://vega.github.io/vega-lite/docs/scale.html#discretizing) scales, an array of desired output values.
    /// __Notes:__
    /// 1) For [sequential](https://vega.github.io/vega-lite/docs/scale.html#sequential), [ordinal](https://vega.github.io/vega-lite/docs/scale.html#ordinal), and discretizing color scales, you can also specify a color [`scheme`](https://vega.github.io/vega-lite/docs/scale.html#scheme) instead of `range`.
    /// 2) Any directly specified `range` for `x` and `y` channels will be ignored. Range can be customized via the view's corresponding [size](https://vega.github.io/vega-lite/docs/size.html) (`width` and `height`) or via [range steps and paddings properties](#range-step) for [band](#band) and [point](#point) scales.
    public var range: RangeChoice?
    /// The distance between the starts of adjacent bands or points in [band](https://vega.github.io/vega-lite/docs/scale.html#band) and [point](https://vega.github.io/vega-lite/docs/scale.html#point) scales.
    /// If `rangeStep` is `null` or if the view contains the scale's corresponding [size](https://vega.github.io/vega-lite/docs/size.html) (`width` for `x` scales and `height` for `y` scales), `rangeStep` will be automatically determined to fit the size of the view.
    /// __Default value:__  derived the [scale config](https://vega.github.io/vega-lite/docs/config.html#scale-config)'s `textXRangeStep` (`90` by default) for x-scales of `text` marks and `rangeStep` (`21` by default) for x-scales of other marks and y-scales.
    /// __Warning__: If `rangeStep` is `null` and the cardinality of the scale's domain is higher than `width` or `height`, the rangeStep might become less than one pixel and the mark might not appear correctly.
    public var rangeStep: RangeStep?
    /// If `true`, rounds numeric output values to integers. This can be helpful for snapping to the pixel grid.
    /// __Default value:__ `false`.
    public var round: Bool?
    /// A string indicating a color [scheme](https://vega.github.io/vega-lite/docs/scale.html#scheme) name (e.g., `"category10"` or `"viridis"`) or a [scheme parameter object](https://vega.github.io/vega-lite/docs/scale.html#scheme-params).
    /// Discrete color schemes may be used with [discrete](https://vega.github.io/vega-lite/docs/scale.html#discrete) or [discretizing](https://vega.github.io/vega-lite/docs/scale.html#discretizing) scales. Continuous color schemes are intended for use with [sequential](https://vega.github.io/vega-lite/docs/scales.html#sequential) scales.
    /// For the full list of supported schemes, please refer to the [Vega Scheme](https://vega.github.io/vega/docs/schemes/#reference) reference.
    public var scheme: SchemeChoice?
    /// The type of scale.  Vega-Lite supports the following categories of scale types:
    /// 1) [**Continuous Scales**](https://vega.github.io/vega-lite/docs/scale.html#continuous) -- mapping continuous domains to continuous output ranges ([`"linear"`](https://vega.github.io/vega-lite/docs/scale.html#linear), [`"pow"`](https://vega.github.io/vega-lite/docs/scale.html#pow), [`"sqrt"`](https://vega.github.io/vega-lite/docs/scale.html#sqrt), [`"log"`](https://vega.github.io/vega-lite/docs/scale.html#log), [`"time"`](https://vega.github.io/vega-lite/docs/scale.html#time), [`"utc"`](https://vega.github.io/vega-lite/docs/scale.html#utc), [`"sequential"`](https://vega.github.io/vega-lite/docs/scale.html#sequential)).
    /// 2) [**Discrete Scales**](https://vega.github.io/vega-lite/docs/scale.html#discrete) -- mapping discrete domains to discrete ([`"ordinal"`](https://vega.github.io/vega-lite/docs/scale.html#ordinal)) or continuous ([`"band"`](https://vega.github.io/vega-lite/docs/scale.html#band) and [`"point"`](https://vega.github.io/vega-lite/docs/scale.html#point)) output ranges.
    /// 3) [**Discretizing Scales**](https://vega.github.io/vega-lite/docs/scale.html#discretizing) -- mapping continuous domains to discrete output ranges ([`"bin-linear"`](https://vega.github.io/vega-lite/docs/scale.html#bin-linear) and [`"bin-ordinal"`](https://vega.github.io/vega-lite/docs/scale.html#bin-ordinal)).
    /// __Default value:__ please see the [scale type table](https://vega.github.io/vega-lite/docs/scale.html#type).
    public var type: ScaleType?
    /// If `true`, ensures that a zero baseline value is included in the scale domain.
    /// __Default value:__ `true` for x and y channels if the quantitative field is not binned and no custom `domain` is provided; `false` otherwise.
    /// __Note:__ Log, time, and utc scales do not support `zero`.
    public var zero: Bool?

    public init(base: Double? = .none, clamp: Bool? = .none, domain: DomainChoice? = .none, exponent: Double? = .none, interpolate: InterpolateChoice? = .none, nice: NiceChoice? = .none, padding: Double? = .none, paddingInner: Double? = .none, paddingOuter: Double? = .none, range: RangeChoice? = .none, rangeStep: RangeStep? = .none, round: Bool? = .none, scheme: SchemeChoice? = .none, type: ScaleType? = .none, zero: Bool? = .none) {
        self.base = base 
        self.clamp = clamp 
        self.domain = domain 
        self.exponent = exponent 
        self.interpolate = interpolate 
        self.nice = nice 
        self.padding = padding 
        self.paddingInner = paddingInner 
        self.paddingOuter = paddingOuter 
        self.range = range 
        self.rangeStep = rangeStep 
        self.round = round 
        self.scheme = scheme 
        self.type = type 
        self.zero = zero 
    }

    public enum CodingKeys : String, CodingKey {
        case base
        case clamp
        case domain
        case exponent
        case interpolate
        case nice
        case padding
        case paddingInner
        case paddingOuter
        case range
        case rangeStep
        case round
        case scheme
        case type
        case zero
    }

    /// Customized domain values.
    /// For _quantitative_ fields, `domain` can take the form of a two-element array with minimum and maximum values.  [Piecewise scales](https://vega.github.io/vega-lite/docs/scale.html#piecewise) can be created by providing a `domain` with more than two entries.
    /// If the input field is aggregated, `domain` can also be a string value `"unaggregated"`, indicating that the domain should include the raw data values prior to the aggregation.
    /// For _temporal_ fields, `domain` can be a two-element array minimum and maximum values, in the form of either timestamps or the [DateTime definition objects](https://vega.github.io/vega-lite/docs/types.html#datetime).
    /// For _ordinal_ and _nominal_ fields, `domain` can be an array that lists valid input values.
    /// The `selection` property can be used to [interactively determine](https://vega.github.io/vega-lite/docs/selection.html#scale-domains) the scale domain.
    public typealias DomainChoice = DomainTypes.Choice
    public enum DomainTypes {

        public typealias Choice = OneOf6<[Double], [String], [Bool], [DateTime], Type5, SelectionDomain>

        public enum Type5 : String, Equatable, Codable {
            case unaggregated
        }
    }

    /// The interpolation method for range values. By default, a general interpolator for numbers, dates, strings and colors (in RGB space) is used. For color ranges, this property allows interpolation in alternative color spaces. Legal values include `rgb`, `hsl`, `hsl-long`, `lab`, `hcl`, `hcl-long`, `cubehelix` and `cubehelix-long` ('-long' variants use longer paths in polar coordinate spaces). If object-valued, this property accepts an object with a string-valued _type_ property and an optional numeric _gamma_ property applicable to rgb and cubehelix interpolators. For more, see the [d3-interpolate documentation](https://github.com/d3/d3-interpolate).
    /// __Note:__ Sequential scales do not support `interpolate` as they have a fixed interpolator.  Since Vega-Lite uses sequential scales for quantitative fields by default, you have to set the scale `type` to other quantitative scale type such as `"linear"` to customize `interpolate`.
    public typealias InterpolateChoice = OneOf2<ScaleInterpolate, ScaleInterpolateParams>

    /// Extending the domain so that it starts and ends on nice round values. This method typically modifies the scale’s domain, and may only extend the bounds to the nearest round value. Nicing is useful if the domain is computed from data and may be irregular. For example, for a domain of _[0.201479…, 0.996679…]_, a nice domain might be _[0.2, 1.0]_.
    /// For quantitative scales such as linear, `nice` can be either a boolean flag or a number. If `nice` is a number, it will represent a desired tick count. This allows greater control over the step size used to extend the bounds, guaranteeing that the returned ticks will exactly cover the domain.
    /// For temporal fields with time and utc scales, the `nice` value can be a string indicating the desired time interval. Legal values are `"millisecond"`, `"second"`, `"minute"`, `"hour"`, `"day"`, `"week"`, `"month"`, and `"year"`. Alternatively, `time` and `utc` scales can accept an object-valued interval specifier of the form `{"interval": "month", "step": 3}`, which includes a desired number of interval steps. Here, the domain would snap to quarter (Jan, Apr, Jul, Oct) boundaries.
    /// __Default value:__ `true` for unbinned _quantitative_ fields; `false` otherwise.
    public typealias NiceChoice = NiceTypes.Choice
    public enum NiceTypes {

        public typealias Choice = OneOf4<Bool, Double, NiceTime, IntervalStepType>

        public struct IntervalStepType : Equatable, Codable {
            public var interval: String
            public var step: Double

            public init(interval: String, step: Double) {
                self.interval = interval 
                self.step = step 
            }

            public enum CodingKeys : String, CodingKey {
                case interval
                case step
            }
        }
    }

    /// The range of the scale. One of:
    /// - A string indicating a [pre-defined named scale range](https://vega.github.io/vega-lite/docs/scale.html#range-config) (e.g., example, `"symbol"`, or `"diverging"`).
    /// - For [continuous scales](https://vega.github.io/vega-lite/docs/scale.html#continuous), two-element array indicating  minimum and maximum values, or an array with more than two entries for specifying a [piecewise scale](https://vega.github.io/vega-lite/docs/scale.html#piecewise).
    /// - For [discrete](https://vega.github.io/vega-lite/docs/scale.html#discrete) and [discretizing](https://vega.github.io/vega-lite/docs/scale.html#discretizing) scales, an array of desired output values.
    /// __Notes:__
    /// 1) For [sequential](https://vega.github.io/vega-lite/docs/scale.html#sequential), [ordinal](https://vega.github.io/vega-lite/docs/scale.html#ordinal), and discretizing color scales, you can also specify a color [`scheme`](https://vega.github.io/vega-lite/docs/scale.html#scheme) instead of `range`.
    /// 2) Any directly specified `range` for `x` and `y` channels will be ignored. Range can be customized via the view's corresponding [size](https://vega.github.io/vega-lite/docs/size.html) (`width` and `height`) or via [range steps and paddings properties](#range-step) for [band](#band) and [point](#point) scales.
    public typealias RangeChoice = OneOf3<[Double], [String], String>

    public typealias RangeStep = OneOf2<Double, ExplicitNull>

    /// A string indicating a color [scheme](https://vega.github.io/vega-lite/docs/scale.html#scheme) name (e.g., `"category10"` or `"viridis"`) or a [scheme parameter object](https://vega.github.io/vega-lite/docs/scale.html#scheme-params).
    /// Discrete color schemes may be used with [discrete](https://vega.github.io/vega-lite/docs/scale.html#discrete) or [discretizing](https://vega.github.io/vega-lite/docs/scale.html#discretizing) scales. Continuous color schemes are intended for use with [sequential](https://vega.github.io/vega-lite/docs/scales.html#sequential) scales.
    /// For the full list of supported schemes, please refer to the [Vega Scheme](https://vega.github.io/vega/docs/schemes/#reference) reference.
    public typealias SchemeChoice = OneOf2<String, SchemeParams>
}

public typealias VgBinding = OneOf5<VgCheckboxBinding, VgRadioBinding, VgSelectBinding, VgRangeBinding, VgGenericBinding>

/// Constants and utilities for data type  
///  Data type based on level of measurement 
public typealias `Type` = OneOf2<BasicType, GeoType>

public typealias Predicate = OneOf9<FieldEqualPredicate, FieldRangePredicate, FieldOneOfPredicate, FieldLTPredicate, FieldGTPredicate, FieldLTEPredicate, FieldGTEPredicate, SelectionPredicate, String>

public struct Axis : Equatable, Codable {
    /// A boolean flag indicating if the domain (the axis baseline) should be included as part of the axis.
    /// __Default value:__ `true`
    public var domain: Bool?
    /// The formatting pattern for labels. This is D3's [number format pattern](https://github.com/d3/d3-format#locale_format) for quantitative fields and D3's [time format pattern](https://github.com/d3/d3-time-format#locale_format) for time field.
    /// See the [format documentation](https://vega.github.io/vega-lite/docs/format.html) for more information.
    /// __Default value:__  derived from [numberFormat](https://vega.github.io/vega-lite/docs/config.html#format) config for quantitative fields and from [timeFormat](https://vega.github.io/vega-lite/docs/config.html#format) config for temporal fields.
    public var format: String?
    /// A boolean flag indicating if grid lines should be included as part of the axis
    /// __Default value:__ `true` for [continuous scales](https://vega.github.io/vega-lite/docs/scale.html#continuous) that are not binned; otherwise, `false`.
    public var grid: Bool?
    /// The rotation angle of the axis labels.
    /// __Default value:__ `-90` for nominal and ordinal fields; `0` otherwise.
    public var labelAngle: Double?
    /// Indicates if labels should be hidden if they exceed the axis range. If `false `(the default) no bounds overlap analysis is performed. If `true`, labels will be hidden if they exceed the axis range by more than 1 pixel. If this property is a number, it specifies the pixel tolerance: the maximum amount by which a label bounding box may exceed the axis range.
    /// __Default value:__ `false`.
    public var labelBound: LabelBound?
    /// Indicates if the first and last axis labels should be aligned flush with the scale range. Flush alignment for a horizontal axis will left-align the first label and right-align the last label. For vertical axes, bottom and top text baselines are applied instead. If this property is a number, it also indicates the number of pixels by which to offset the first and last labels; for example, a value of 2 will flush-align the first and last labels and also push them 2 pixels outward from the center of the axis. The additional adjustment can sometimes help the labels better visually group with corresponding axis ticks.
    /// __Default value:__ `true` for axis of a continuous x-scale. Otherwise, `false`.
    public var labelFlush: LabelFlush?
    /// The strategy to use for resolving overlap of axis labels. If `false` (the default), no overlap reduction is attempted. If set to `true` or `"parity"`, a strategy of removing every other label is used (this works well for standard linear axes). If set to `"greedy"`, a linear scan of the labels is performed, removing any labels that overlaps with the last visible label (this often works better for log-scaled axes).
    /// __Default value:__ `true` for non-nominal fields with non-log scales; `"greedy"` for log scales; otherwise `false`.
    public var labelOverlap: LabelOverlapChoice?
    /// The padding, in pixels, between axis and text labels.
    public var labelPadding: Double?
    /// A boolean flag indicating if labels should be included as part of the axis.
    /// __Default value:__  `true`.
    public var labels: Bool?
    /// The maximum extent in pixels that axis ticks and labels should use. This determines a maximum offset value for axis titles.
    /// __Default value:__ `undefined`.
    public var maxExtent: Double?
    /// The minimum extent in pixels that axis ticks and labels should use. This determines a minimum offset value for axis titles.
    /// __Default value:__ `30` for y-axis; `undefined` for x-axis.
    public var minExtent: Double?
    /// The offset, in pixels, by which to displace the axis from the edge of the enclosing group or data rectangle.
    /// __Default value:__ derived from the [axis config](https://vega.github.io/vega-lite/docs/config.html#facet-scale-config)'s `offset` (`0` by default)
    public var offset: Double?
    /// The orientation of the axis. One of `"top"`, `"bottom"`, `"left"` or `"right"`. The orientation can be used to further specialize the axis type (e.g., a y axis oriented for the right edge of the chart).
    /// __Default value:__ `"bottom"` for x-axes and `"left"` for y-axes.
    public var orient: AxisOrient?
    /// The anchor position of the axis in pixels. For x-axis with top or bottom orientation, this sets the axis group x coordinate. For y-axis with left or right orientation, this sets the axis group y coordinate.
    /// __Default value__: `0`
    public var position: Double?
    /// A desired number of ticks, for axes visualizing quantitative scales. The resulting number may be different so that values are "nice" (multiples of 2, 5, 10) and lie within the underlying scale's range.
    public var tickCount: Double?
    /// The size in pixels of axis ticks.
    public var tickSize: Double?
    /// Boolean value that determines whether the axis should include ticks.
    public var ticks: Bool?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?
    /// Max length for axis title if the title is automatically generated from the field's description.
    public var titleMaxLength: Double?
    /// The padding, in pixels, between title and axis.
    public var titlePadding: Double?
    /// Explicitly set the visible axis tick values.
    public var values: ValuesChoice?
    /// A non-positive integer indicating z-index of the axis.
    /// If zindex is 0, axes should be drawn behind all chart elements.
    /// To put them in front, use `"zindex = 1"`.
    /// __Default value:__ `1` (in front of the marks) for actual axis and `0` (behind the marks) for grids.
    public var zindex: Double?

    public init(domain: Bool? = .none, format: String? = .none, grid: Bool? = .none, labelAngle: Double? = .none, labelBound: LabelBound? = .none, labelFlush: LabelFlush? = .none, labelOverlap: LabelOverlapChoice? = .none, labelPadding: Double? = .none, labels: Bool? = .none, maxExtent: Double? = .none, minExtent: Double? = .none, offset: Double? = .none, orient: AxisOrient? = .none, position: Double? = .none, tickCount: Double? = .none, tickSize: Double? = .none, ticks: Bool? = .none, title: Title? = .none, titleMaxLength: Double? = .none, titlePadding: Double? = .none, values: ValuesChoice? = .none, zindex: Double? = .none) {
        self.domain = domain 
        self.format = format 
        self.grid = grid 
        self.labelAngle = labelAngle 
        self.labelBound = labelBound 
        self.labelFlush = labelFlush 
        self.labelOverlap = labelOverlap 
        self.labelPadding = labelPadding 
        self.labels = labels 
        self.maxExtent = maxExtent 
        self.minExtent = minExtent 
        self.offset = offset 
        self.orient = orient 
        self.position = position 
        self.tickCount = tickCount 
        self.tickSize = tickSize 
        self.ticks = ticks 
        self.title = title 
        self.titleMaxLength = titleMaxLength 
        self.titlePadding = titlePadding 
        self.values = values 
        self.zindex = zindex 
    }

    public enum CodingKeys : String, CodingKey {
        case domain
        case format
        case grid
        case labelAngle
        case labelBound
        case labelFlush
        case labelOverlap
        case labelPadding
        case labels
        case maxExtent
        case minExtent
        case offset
        case orient
        case position
        case tickCount
        case tickSize
        case ticks
        case title
        case titleMaxLength
        case titlePadding
        case values
        case zindex
    }

    public typealias LabelBound = OneOf2<Bool, Double>

    public typealias LabelFlush = OneOf2<Bool, Double>

    /// The strategy to use for resolving overlap of axis labels. If `false` (the default), no overlap reduction is attempted. If set to `true` or `"parity"`, a strategy of removing every other label is used (this works well for standard linear axes). If set to `"greedy"`, a linear scan of the labels is performed, removing any labels that overlaps with the last visible label (this often works better for log-scaled axes).
    /// __Default value:__ `true` for non-nominal fields with non-log scales; `"greedy"` for log scales; otherwise `false`.
    public typealias LabelOverlapChoice = LabelOverlapTypes.Choice
    public enum LabelOverlapTypes {

        public typealias Choice = OneOf3<Bool, Type2, Type3>

        public enum Type2 : String, Equatable, Codable {
            case parity
        }

        public enum Type3 : String, Equatable, Codable {
            case greedy
        }
    }

    public typealias Title = OneOf2<String, ExplicitNull>

    /// Explicitly set the visible axis tick values.
    public typealias ValuesChoice = OneOf2<[Double], [DateTime]>
}

public typealias FontWeightNumber = Double

public struct DsvDataFormat : Equatable, Codable {
    /// The delimiter between records. The delimiter must be a single character (i.e., a single 16-bit code unit); so, ASCII delimiters are fine, but emoji delimiters are not.
    public var delimiter: String
    /// If set to `"auto"` (the default), perform automatic type inference to determine the desired data types.
    /// If set to `null`, disable type inference based on the spec and only use type inference based on the data.
    /// Alternatively, a parsing directive object can be provided for explicit data types. Each property of the object corresponds to a field name, and the value to the desired data type (one of `"number"`, `"boolean"`, `"date"`, or null (do not parse the field)).
    /// For example, `"parse": {"modified_on": "date"}` parses the `modified_on` field in each input record a Date value.
    /// For `"date"`, we parse data based using Javascript's [`Date.parse()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse).
    /// For Specific date formats can be provided (e.g., `{foo: 'date:"%m%d%Y"'}`), using the [d3-time-format syntax](https://github.com/d3/d3-time-format#locale_format). UTC date format parsing is supported similarly (e.g., `{foo: 'utc:"%m%d%Y"'}`). See more about [UTC time](https://vega.github.io/vega-lite/docs/timeunit.html#utc)
    public var parse: ParseChoice?
    /// Type of input data: `"json"`, `"csv"`, `"tsv"`, `"dsv"`.
    /// The default format type is determined by the extension of the file URL.
    /// If no extension is detected, `"json"` will be used by default.
    public var type: `Type`?

    public init(delimiter: String, parse: ParseChoice? = .none, type: `Type`? = .none) {
        self.delimiter = delimiter 
        self.parse = parse 
        self.type = type 
    }

    public enum CodingKeys : String, CodingKey {
        case delimiter
        case parse
        case type
    }

    /// If set to `"auto"` (the default), perform automatic type inference to determine the desired data types.
    /// If set to `null`, disable type inference based on the spec and only use type inference based on the data.
    /// Alternatively, a parsing directive object can be provided for explicit data types. Each property of the object corresponds to a field name, and the value to the desired data type (one of `"number"`, `"boolean"`, `"date"`, or null (do not parse the field)).
    /// For example, `"parse": {"modified_on": "date"}` parses the `modified_on` field in each input record a Date value.
    /// For `"date"`, we parse data based using Javascript's [`Date.parse()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse).
    /// For Specific date formats can be provided (e.g., `{foo: 'date:"%m%d%Y"'}`), using the [d3-time-format syntax](https://github.com/d3/d3-time-format#locale_format). UTC date format parsing is supported similarly (e.g., `{foo: 'utc:"%m%d%Y"'}`). See more about [UTC time](https://vega.github.io/vega-lite/docs/timeunit.html#utc)
    public typealias ParseChoice = ParseTypes.Choice
    public enum ParseTypes {

        public typealias Choice = OneOf3<Type1, Parse, ExplicitNull>

        public enum Type1 : String, Equatable, Codable {
            case auto
        }
    }

    /// Type of input data: `"json"`, `"csv"`, `"tsv"`, `"dsv"`.
    /// The default format type is determined by the extension of the file URL.
    /// If no extension is detected, `"json"` will be used by default.
    public enum `Type` : String, Equatable, Codable {
        case dsv
    }
}

public typealias AnyMark = OneOf2<Mark, MarkDef>

public struct JsonDataFormat : Equatable, Codable {
    /// If set to `"auto"` (the default), perform automatic type inference to determine the desired data types.
    /// If set to `null`, disable type inference based on the spec and only use type inference based on the data.
    /// Alternatively, a parsing directive object can be provided for explicit data types. Each property of the object corresponds to a field name, and the value to the desired data type (one of `"number"`, `"boolean"`, `"date"`, or null (do not parse the field)).
    /// For example, `"parse": {"modified_on": "date"}` parses the `modified_on` field in each input record a Date value.
    /// For `"date"`, we parse data based using Javascript's [`Date.parse()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse).
    /// For Specific date formats can be provided (e.g., `{foo: 'date:"%m%d%Y"'}`), using the [d3-time-format syntax](https://github.com/d3/d3-time-format#locale_format). UTC date format parsing is supported similarly (e.g., `{foo: 'utc:"%m%d%Y"'}`). See more about [UTC time](https://vega.github.io/vega-lite/docs/timeunit.html#utc)
    public var parse: ParseChoice?
    /// The JSON property containing the desired data.
    /// This parameter can be used when the loaded JSON file may have surrounding structure or meta-data.
    /// For example `"property": "values.features"` is equivalent to retrieving `json.values.features`
    /// from the loaded JSON object.
    public var property: String?
    /// Type of input data: `"json"`, `"csv"`, `"tsv"`, `"dsv"`.
    /// The default format type is determined by the extension of the file URL.
    /// If no extension is detected, `"json"` will be used by default.
    public var type: `Type`?

    public init(parse: ParseChoice? = .none, property: String? = .none, type: `Type`? = .none) {
        self.parse = parse 
        self.property = property 
        self.type = type 
    }

    public enum CodingKeys : String, CodingKey {
        case parse
        case property
        case type
    }

    /// If set to `"auto"` (the default), perform automatic type inference to determine the desired data types.
    /// If set to `null`, disable type inference based on the spec and only use type inference based on the data.
    /// Alternatively, a parsing directive object can be provided for explicit data types. Each property of the object corresponds to a field name, and the value to the desired data type (one of `"number"`, `"boolean"`, `"date"`, or null (do not parse the field)).
    /// For example, `"parse": {"modified_on": "date"}` parses the `modified_on` field in each input record a Date value.
    /// For `"date"`, we parse data based using Javascript's [`Date.parse()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse).
    /// For Specific date formats can be provided (e.g., `{foo: 'date:"%m%d%Y"'}`), using the [d3-time-format syntax](https://github.com/d3/d3-time-format#locale_format). UTC date format parsing is supported similarly (e.g., `{foo: 'utc:"%m%d%Y"'}`). See more about [UTC time](https://vega.github.io/vega-lite/docs/timeunit.html#utc)
    public typealias ParseChoice = ParseTypes.Choice
    public enum ParseTypes {

        public typealias Choice = OneOf3<Type1, Parse, ExplicitNull>

        public enum Type1 : String, Equatable, Codable {
            case auto
        }
    }

    /// Type of input data: `"json"`, `"csv"`, `"tsv"`, `"dsv"`.
    /// The default format type is determined by the extension of the file URL.
    /// If no extension is detected, `"json"` will be used by default.
    public enum `Type` : String, Equatable, Codable {
        case json
    }
}

/// A FieldDef with Condition<ValueDef>
/// {
///    condition: {value: ...},
///    field: ...,
///    ...
/// }
public struct TextFieldDefWithCondition : Equatable, Codable {
    /// The encoded field's type of measurement (`"quantitative"`, `"temporal"`, `"ordinal"`, or `"nominal"`).
    /// It can also be a `"geojson"` type for encoding ['geoshape'](https://vega.github.io/vega-lite/docs/geoshape.html).
    public var type: `Type`
    /// Aggregation function for the field
    /// (e.g., `mean`, `sum`, `median`, `min`, `max`, `count`).
    /// __Default value:__ `undefined` (None)
    public var aggregate: Aggregate?
    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public var bin: BinChoice?
    /// One or more value definition(s) with a selection predicate.
    /// __Note:__ A field definition's `condition` property can only contain [value definitions](https://vega.github.io/vega-lite/docs/encoding.html#value-def)
    /// since Vega-Lite only allows at most one encoded field per encoding channel.
    public var condition: ConditionChoice?
    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public var field: FieldChoice?
    /// The [formatting pattern](https://vega.github.io/vega-lite/docs/format.html) for a text field. If not defined, this will be determined automatically.
    public var format: String?
    /// Time unit (e.g., `year`, `yearmonth`, `month`, `hours`) for a temporal field.
    /// or [a temporal field that gets casted as ordinal](https://vega.github.io/vega-lite/docs/type.html#cast).
    /// __Default value:__ `undefined` (None)
    public var timeUnit: TimeUnit?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?

    public init(type: `Type`, aggregate: Aggregate? = .none, bin: BinChoice? = .none, condition: ConditionChoice? = .none, field: FieldChoice? = .none, format: String? = .none, timeUnit: TimeUnit? = .none, title: Title? = .none) {
        self.type = type 
        self.aggregate = aggregate 
        self.bin = bin 
        self.condition = condition 
        self.field = field 
        self.format = format 
        self.timeUnit = timeUnit 
        self.title = title 
    }

    public enum CodingKeys : String, CodingKey {
        case type
        case aggregate
        case bin
        case condition
        case field
        case format
        case timeUnit
        case title
    }

    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public typealias BinChoice = OneOf2<Bool, BinParams>

    /// One or more value definition(s) with a selection predicate.
    /// __Note:__ A field definition's `condition` property can only contain [value definitions](https://vega.github.io/vega-lite/docs/encoding.html#value-def)
    /// since Vega-Lite only allows at most one encoded field per encoding channel.
    public typealias ConditionChoice = OneOf2<ConditionalValueDef, [ConditionalValueDef]>

    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public typealias FieldChoice = OneOf2<String, RepeatRef>

    /// A FieldDef with Condition<ValueDef>
    /// {
    ///    condition: {value: ...},
    ///    field: ...,
    ///    ...
    /// }
    public typealias Title = OneOf2<String, ExplicitNull>
}

public typealias Month = Double

public struct BinTransform : Equatable, Codable {
    /// An object indicating bin properties, or simply `true` for using default bin parameters.
    public var bin: BinChoice
    /// The data field to bin.
    public var field: String
    /// The output fields at which to write the start and end bin values.
    public var `as`: String

    public init(bin: BinChoice, field: String, `as`: String) {
        self.bin = bin 
        self.field = field 
        self.`as` = `as` 
    }

    public enum CodingKeys : String, CodingKey {
        case bin
        case field
        case `as` = "as"
    }

    /// An object indicating bin properties, or simply `true` for using default bin parameters.
    public typealias BinChoice = OneOf2<Bool, BinParams>
}

public struct FieldOneOfPredicate : Equatable, Codable {
    /// Field to be filtered.
    public var field: String
    /// A set of values that the `field`'s value should be a member of,
    /// for a data item included in the filtered data.
    public var oneOf: OneOfChoice
    /// Time unit for the field to be filtered.
    public var timeUnit: TimeUnit?

    public init(field: String, oneOf: OneOfChoice, timeUnit: TimeUnit? = .none) {
        self.field = field 
        self.oneOf = oneOf 
        self.timeUnit = timeUnit 
    }

    public enum CodingKeys : String, CodingKey {
        case field
        case oneOf
        case timeUnit
    }

    /// A set of values that the `field`'s value should be a member of,
    /// for a data item included in the filtered data.
    public typealias OneOfChoice = OneOf4<[String], [Double], [Bool], [DateTime]>
}

public struct AggregateTransform : Equatable, Codable {
    /// Array of objects that define fields to aggregate.
    public var aggregate: [AggregatedFieldDef]
    /// The data fields to group by. If not specified, a single group containing all data objects will be used.
    public var groupby: [GroupbyItem]?

    public init(aggregate: [AggregatedFieldDef] = [], groupby: [GroupbyItem]? = .none) {
        self.aggregate = aggregate 
        self.groupby = groupby 
    }

    public enum CodingKeys : String, CodingKey {
        case aggregate
        case groupby
    }

    public typealias GroupbyItem = String
}

public struct RangeConfig : Equatable, Codable {
    /// Default range for _nominal_ (categorical) fields.
    public var category: CategoryChoice?
    /// Default range for diverging _quantitative_ fields.
    public var diverging: DivergingChoice?
    /// Default range for _quantitative_ heatmaps.
    public var heatmap: HeatmapChoice?
    /// Default range for _ordinal_ fields.
    public var ordinal: OrdinalChoice?
    /// Default range for _quantitative_ and _temporal_ fields.
    public var ramp: RampChoice?
    /// Default range palette for the `shape` channel.
    public var symbol: [SymbolItem]?
    public var additionalProperties: Dictionary<String, Bric>

    public init(category: CategoryChoice? = .none, diverging: DivergingChoice? = .none, heatmap: HeatmapChoice? = .none, ordinal: OrdinalChoice? = .none, ramp: RampChoice? = .none, symbol: [SymbolItem]? = .none, additionalProperties: Dictionary<String, Bric> = [:]) {
        self.category = category 
        self.diverging = diverging 
        self.heatmap = heatmap 
        self.ordinal = ordinal 
        self.ramp = ramp 
        self.symbol = symbol 
        self.additionalProperties = additionalProperties 
    }

    public enum CodingKeys : String, CodingKey {
        case category
        case diverging
        case heatmap
        case ordinal
        case ramp
        case symbol
        case additionalProperties = ""
    }

    /// Default range for _nominal_ (categorical) fields.
    public typealias CategoryChoice = OneOf2<[String], VgScheme>

    /// Default range for diverging _quantitative_ fields.
    public typealias DivergingChoice = OneOf2<[String], VgScheme>

    /// Default range for _quantitative_ heatmaps.
    public typealias HeatmapChoice = OneOf2<[String], VgScheme>

    /// Default range for _ordinal_ fields.
    public typealias OrdinalChoice = OneOf2<[String], VgScheme>

    /// Default range for _quantitative_ and _temporal_ fields.
    public typealias RampChoice = OneOf2<[String], VgScheme>

    public typealias SymbolItem = String
}

public struct ConditionalPredicateValueDef : Equatable, Codable {
    public var test: LogicalOperandPredicate
    /// A constant value in visual domain (e.g., `"red"` / "#0099ff" for color, values between `0` to `1` for opacity).
    public var value: Value

    public init(test: LogicalOperandPredicate, value: Value) {
        self.test = test 
        self.value = value 
    }

    public enum CodingKeys : String, CodingKey {
        case test
        case value
    }

    public typealias Value = OneOf3<Double, String, Bool>
}

public struct NamedData : Equatable, Codable {
    /// Provide a placeholder name and bind data at runtime.
    public var name: String
    /// An object that specifies the format for parsing the data.
    public var format: DataFormat?

    public init(name: String, format: DataFormat? = .none) {
        self.name = name 
        self.format = format 
    }

    public enum CodingKeys : String, CodingKey {
        case name
        case format
    }
}

public struct LookupData : Equatable, Codable {
    /// Secondary data source to lookup in.
    public var data: Data
    /// Key in data to lookup.
    public var key: String
    /// Fields in foreign data to lookup.
    /// If not specified, the entire object is queried.
    public var fields: [FieldsItem]?

    public init(data: Data, key: String, fields: [FieldsItem]? = .none) {
        self.data = data 
        self.key = key 
        self.fields = fields 
    }

    public enum CodingKeys : String, CodingKey {
        case data
        case key
        case fields
    }

    public typealias FieldsItem = String
}

public typealias Datasets = DictInlineDataset

public struct MultiSelectionConfig : Equatable, Codable {
    /// By default, all data values are considered to lie within an empty selection.
    /// When set to `none`, empty selections contain no data values.
    public var empty: Empty?
    /// An array of encoding channels. The corresponding data field values
    /// must match for a data tuple to fall within the selection.
    public var encodings: [SingleDefChannel]?
    /// An array of field names whose values must match for a data tuple to
    /// fall within the selection.
    public var fields: [FieldsItem]?
    /// When true, an invisible voronoi diagram is computed to accelerate discrete
    /// selection. The data value _nearest_ the mouse cursor is added to the selection.
    /// See the [nearest transform](https://vega.github.io/vega-lite/docs/nearest.html) documentation for more information.
    public var nearest: Bool?
    /// A [Vega event stream](https://vega.github.io/vega/docs/event-streams/) (object or selector) that triggers the selection.
    /// For interval selections, the event stream must specify a [start and end](https://vega.github.io/vega/docs/event-streams/#between-filters).
    public var on: VgEventStream?
    /// With layered and multi-view displays, a strategy that determines how
    /// selections' data queries are resolved when applied in a filter transform,
    /// conditional encoding rule, or scale domain.
    public var resolve: SelectionResolution?
    /// Controls whether data values should be toggled or only ever inserted into
    /// multi selections. Can be `true`, `false` (for insertion only), or a
    /// [Vega expression](https://vega.github.io/vega/docs/expressions/).
    /// __Default value:__ `true`, which corresponds to `event.shiftKey` (i.e.,
    /// data values are toggled when a user interacts with the shift-key pressed).
    /// See the [toggle transform](https://vega.github.io/vega-lite/docs/toggle.html) documentation for more information.
    public var toggle: Toggle?

    public init(empty: Empty? = .none, encodings: [SingleDefChannel]? = .none, fields: [FieldsItem]? = .none, nearest: Bool? = .none, on: VgEventStream? = .none, resolve: SelectionResolution? = .none, toggle: Toggle? = .none) {
        self.empty = empty 
        self.encodings = encodings 
        self.fields = fields 
        self.nearest = nearest 
        self.on = on 
        self.resolve = resolve 
        self.toggle = toggle 
    }

    public enum CodingKeys : String, CodingKey {
        case empty
        case encodings
        case fields
        case nearest
        case on
        case resolve
        case toggle
    }

    /// By default, all data values are considered to lie within an empty selection.
    /// When set to `none`, empty selections contain no data values.
    public enum Empty : String, Equatable, Codable {
        case all
        case none
    }

    public typealias FieldsItem = String

    public typealias Toggle = OneOf2<String, Bool>
}

public struct SingleSelectionConfig : Equatable, Codable {
    /// Establish a two-way binding between a single selection and input elements
    /// (also known as dynamic query widgets). A binding takes the form of
    /// Vega's [input element binding definition](https://vega.github.io/vega/docs/signals/#bind)
    /// or can be a mapping between projected field/encodings and binding definitions.
    /// See the [bind transform](https://vega.github.io/vega-lite/docs/bind.html) documentation for more information.
    public var bind: BindChoice?
    /// By default, all data values are considered to lie within an empty selection.
    /// When set to `none`, empty selections contain no data values.
    public var empty: Empty?
    /// An array of encoding channels. The corresponding data field values
    /// must match for a data tuple to fall within the selection.
    public var encodings: [SingleDefChannel]?
    /// An array of field names whose values must match for a data tuple to
    /// fall within the selection.
    public var fields: [FieldsItem]?
    /// When true, an invisible voronoi diagram is computed to accelerate discrete
    /// selection. The data value _nearest_ the mouse cursor is added to the selection.
    /// See the [nearest transform](https://vega.github.io/vega-lite/docs/nearest.html) documentation for more information.
    public var nearest: Bool?
    /// A [Vega event stream](https://vega.github.io/vega/docs/event-streams/) (object or selector) that triggers the selection.
    /// For interval selections, the event stream must specify a [start and end](https://vega.github.io/vega/docs/event-streams/#between-filters).
    public var on: VgEventStream?
    /// With layered and multi-view displays, a strategy that determines how
    /// selections' data queries are resolved when applied in a filter transform,
    /// conditional encoding rule, or scale domain.
    public var resolve: SelectionResolution?

    public init(bind: BindChoice? = .none, empty: Empty? = .none, encodings: [SingleDefChannel]? = .none, fields: [FieldsItem]? = .none, nearest: Bool? = .none, on: VgEventStream? = .none, resolve: SelectionResolution? = .none) {
        self.bind = bind 
        self.empty = empty 
        self.encodings = encodings 
        self.fields = fields 
        self.nearest = nearest 
        self.on = on 
        self.resolve = resolve 
    }

    public enum CodingKeys : String, CodingKey {
        case bind
        case empty
        case encodings
        case fields
        case nearest
        case on
        case resolve
    }

    /// Establish a two-way binding between a single selection and input elements
    /// (also known as dynamic query widgets). A binding takes the form of
    /// Vega's [input element binding definition](https://vega.github.io/vega/docs/signals/#bind)
    /// or can be a mapping between projected field/encodings and binding definitions.
    /// See the [bind transform](https://vega.github.io/vega-lite/docs/bind.html) documentation for more information.
    public typealias BindChoice = BindTypes.Choice
    public enum BindTypes {

        public typealias Choice = OneOf2<VgBinding, Type2>

        public typealias Type2 = Dictionary<String, Type2Value>
        public typealias Type2Value = VgBinding
    }

    /// By default, all data values are considered to lie within an empty selection.
    /// When set to `none`, empty selections contain no data values.
    public enum Empty : String, Equatable, Codable {
        case all
        case none
    }

    public typealias FieldsItem = String
}

public struct HConcatSpec : Equatable, Codable {
    /// A list of views that should be concatenated and put into a row.
    public var hconcat: [Spec]
    /// An object describing the data source
    public var data: Data?
    /// Description of this mark for commenting purpose.
    public var description: String?
    /// Name of the visualization for later reference.
    public var name: String?
    /// Scale, axis, and legend resolutions for horizontally concatenated charts.
    public var resolve: Resolve?
    /// Title for the plot.
    public var title: TitleChoice?
    /// An array of data transformations such as filter and new field calculation.
    public var transform: [Transform]?

    public init(hconcat: [Spec] = [], data: Data? = .none, description: String? = .none, name: String? = .none, resolve: Resolve? = .none, title: TitleChoice? = .none, transform: [Transform]? = .none) {
        self.hconcat = hconcat 
        self.data = data 
        self.description = description 
        self.name = name 
        self.resolve = resolve 
        self.title = title 
        self.transform = transform 
    }

    public enum CodingKeys : String, CodingKey {
        case hconcat
        case data
        case description
        case name
        case resolve
        case title
        case transform
    }

    /// Title for the plot.
    public typealias TitleChoice = OneOf2<String, TitleParams>
}

public enum FontWeightString : String, Equatable, Codable {
    case normal
    case bold
}

/// A sort definition for transform
public struct SortField : Equatable, Codable {
    /// The name of the field to sort.
    public var field: String
    /// Whether to sort the field in ascending or descending order.
    public var order: VgComparatorOrder?

    public init(field: String, order: VgComparatorOrder? = .none) {
        self.field = field 
        self.order = order 
    }

    public enum CodingKeys : String, CodingKey {
        case field
        case order
    }
}

public enum VgProjectionType : String, Equatable, Codable {
    case albers
    case albersUsa
    case azimuthalEqualArea
    case azimuthalEquidistant
    case conicConformal
    case conicEqualArea
    case conicEquidistant
    case equirectangular
    case gnomonic
    case mercator
    case orthographic
    case stereographic
    case transverseMercator
}

public typealias InlineDataset = OneOf6<[Double], [String], [Bool], [Dictionary<String, Bric>], String, Dictionary<String, Bric>>

public struct LookupTransform : Equatable, Codable {
    /// Key in primary data source.
    public var lookup: String
    /// Secondary data reference.
    public var from: LookupData
    /// The field or fields for storing the computed formula value.
    /// If `from.fields` is specified, the transform will use the same names for `as`.
    /// If `from.fields` is not specified, `as` has to be a string and we put the whole object into the data under the specified name.
    public var `as`: AsChoice?
    /// The default value to use if lookup fails.
    /// __Default value:__ `null`
    public var `default`: String?

    public init(lookup: String, from: LookupData, `as`: AsChoice? = .none, `default`: String? = .none) {
        self.lookup = lookup 
        self.from = from 
        self.`as` = `as` 
        self.`default` = `default` 
    }

    public enum CodingKeys : String, CodingKey {
        case lookup
        case from
        case `as` = "as"
        case `default` = "default"
    }

    /// The field or fields for storing the computed formula value.
    /// If `from.fields` is specified, the transform will use the same names for `as`.
    /// If `from.fields` is not specified, `as` has to be a string and we put the whole object into the data under the specified name.
    public typealias AsChoice = OneOf2<String, [String]>
}

public struct InlineData : Equatable, Codable {
    /// The full data set, included inline. This can be an array of objects or primitive values, an object, or a string.
    /// Arrays of primitive values are ingested as objects with a `data` property. Strings are parsed according to the specified format type.
    public var values: InlineDataset
    /// An object that specifies the format for parsing the data.
    public var format: DataFormat?
    /// Provide a placeholder name and bind data at runtime.
    public var name: String?

    public init(values: InlineDataset, format: DataFormat? = .none, name: String? = .none) {
        self.values = values 
        self.format = format 
        self.name = name 
    }

    public enum CodingKeys : String, CodingKey {
        case values
        case format
        case name
    }
}

public struct EncodingWithFacet : Equatable, Codable {
    /// Color of the marks – either fill or stroke color based on  the `filled` property of mark definition.
    /// By default, `color` represents fill color for `"area"`, `"bar"`, `"tick"`,
    /// `"text"`, `"trail"`, `"circle"`, and `"square"` / stroke color for `"line"` and `"point"`.
    /// __Default value:__ If undefined, the default color depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `color` property.
    /// _Note:_
    /// 1) For fine-grained control over both fill and stroke colors of the marks, please use the `fill` and `stroke` channels.  If either `fill` or `stroke` channel is specified, `color` channel will be ignored.
    /// 2) See the scale documentation for more information about customizing [color scheme](https://vega.github.io/vega-lite/docs/scale.html#scheme).
    public var color: ColorChoice?
    /// Horizontal facets for trellis plots.
    public var column: FacetFieldDef?
    /// Additional levels of detail for grouping data in aggregate views and
    /// in line, trail, and area marks without mapping data to a specific visual channel.
    public var detail: DetailChoice?
    /// Fill color of the marks.
    /// __Default value:__ If undefined, the default color depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `color` property.
    /// _Note:_ When using `fill` channel, `color ` channel will be ignored. To customize both fill and stroke, please use `fill` and `stroke` channels (not `fill` and `color`).
    public var fill: FillChoice?
    /// A URL to load upon mouse click.
    public var href: HrefChoice?
    /// A data field to use as a unique key for data binding. When a visualization’s data is updated, the key value will be used to match data elements to existing mark instances. Use a key channel to enable object constancy for transitions over dynamic data.
    public var key: FieldDef?
    /// Latitude position of geographically projected marks.
    public var latitude: FieldDef?
    /// Latitude-2 position for geographically projected ranged `"area"`, `"bar"`, `"rect"`, and  `"rule"`.
    public var latitude2: FieldDef?
    /// Longitude position of geographically projected marks.
    public var longitude: FieldDef?
    /// Longitude-2 position for geographically projected ranged `"area"`, `"bar"`, `"rect"`, and  `"rule"`.
    public var longitude2: FieldDef?
    /// Opacity of the marks – either can be a value or a range.
    /// __Default value:__ If undefined, the default opacity depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `opacity` property.
    public var opacity: OpacityChoice?
    /// Order of the marks.
    /// - For stacked marks, this `order` channel encodes [stack order](https://vega.github.io/vega-lite/docs/stack.html#order).
    /// - For line and trail marks, this `order` channel encodes order of data points in the lines. This can be useful for creating [a connected scatterplot](https://vega.github.io/vega-lite/examples/connected_scatterplot.html).  Setting `order` to `{"value": null}` makes the line marks use the original order in the data sources.
    /// - Otherwise, this `order` channel encodes layer order of the marks.
    /// __Note__: In aggregate plots, `order` field should be `aggregate`d to avoid creating additional aggregation grouping.
    public var order: OrderChoice?
    /// Vertical facets for trellis plots.
    public var row: FacetFieldDef?
    /// For `point` marks the supported values are
    /// `"circle"` (default), `"square"`, `"cross"`, `"diamond"`, `"triangle-up"`,
    /// or `"triangle-down"`, or else a custom SVG path string.
    /// For `geoshape` marks it should be a field definition of the geojson data
    /// __Default value:__ If undefined, the default shape depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#point-config)'s `shape` property.
    public var shape: ShapeChoice?
    /// Size of the mark.
    /// - For `"point"`, `"square"` and `"circle"`, – the symbol size, or pixel area of the mark.
    /// - For `"bar"` and `"tick"` – the bar and tick's size.
    /// - For `"text"` – the text's font size.
    /// - Size is unsupported for `"line"`, `"area"`, and `"rect"`. (Use `"trail"` instead of line with varying size)
    public var size: SizeChoice?
    /// Stroke color of the marks.
    /// __Default value:__ If undefined, the default color depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `color` property.
    /// _Note:_ When using `stroke` channel, `color ` channel will be ignored. To customize both stroke and fill, please use `stroke` and `fill` channels (not `stroke` and `color`).
    public var stroke: StrokeChoice?
    /// Text of the `text` mark.
    public var text: TextChoice?
    /// The tooltip text to show upon mouse hover.
    public var tooltip: TooltipChoice?
    /// X coordinates of the marks, or width of horizontal `"bar"` and `"area"`.
    public var x: XChoice?
    /// X2 coordinates for ranged `"area"`, `"bar"`, `"rect"`, and  `"rule"`.
    public var x2: X2Choice?
    /// Y coordinates of the marks, or height of vertical `"bar"` and `"area"`.
    public var y: YChoice?
    /// Y2 coordinates for ranged `"area"`, `"bar"`, `"rect"`, and  `"rule"`.
    public var y2: Y2Choice?

    public init(color: ColorChoice? = .none, column: FacetFieldDef? = .none, detail: DetailChoice? = .none, fill: FillChoice? = .none, href: HrefChoice? = .none, key: FieldDef? = .none, latitude: FieldDef? = .none, latitude2: FieldDef? = .none, longitude: FieldDef? = .none, longitude2: FieldDef? = .none, opacity: OpacityChoice? = .none, order: OrderChoice? = .none, row: FacetFieldDef? = .none, shape: ShapeChoice? = .none, size: SizeChoice? = .none, stroke: StrokeChoice? = .none, text: TextChoice? = .none, tooltip: TooltipChoice? = .none, x: XChoice? = .none, x2: X2Choice? = .none, y: YChoice? = .none, y2: Y2Choice? = .none) {
        self.color = color 
        self.column = column 
        self.detail = detail 
        self.fill = fill 
        self.href = href 
        self.key = key 
        self.latitude = latitude 
        self.latitude2 = latitude2 
        self.longitude = longitude 
        self.longitude2 = longitude2 
        self.opacity = opacity 
        self.order = order 
        self.row = row 
        self.shape = shape 
        self.size = size 
        self.stroke = stroke 
        self.text = text 
        self.tooltip = tooltip 
        self.x = x 
        self.x2 = x2 
        self.y = y 
        self.y2 = y2 
    }

    public enum CodingKeys : String, CodingKey {
        case color
        case column
        case detail
        case fill
        case href
        case key
        case latitude
        case latitude2
        case longitude
        case longitude2
        case opacity
        case order
        case row
        case shape
        case size
        case stroke
        case text
        case tooltip
        case x
        case x2
        case y
        case y2
    }

    /// Color of the marks – either fill or stroke color based on  the `filled` property of mark definition.
    /// By default, `color` represents fill color for `"area"`, `"bar"`, `"tick"`,
    /// `"text"`, `"trail"`, `"circle"`, and `"square"` / stroke color for `"line"` and `"point"`.
    /// __Default value:__ If undefined, the default color depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `color` property.
    /// _Note:_
    /// 1) For fine-grained control over both fill and stroke colors of the marks, please use the `fill` and `stroke` channels.  If either `fill` or `stroke` channel is specified, `color` channel will be ignored.
    /// 2) See the scale documentation for more information about customizing [color scheme](https://vega.github.io/vega-lite/docs/scale.html#scheme).
    public typealias ColorChoice = OneOf2<MarkPropFieldDefWithCondition, MarkPropValueDefWithCondition>

    /// Additional levels of detail for grouping data in aggregate views and
    /// in line, trail, and area marks without mapping data to a specific visual channel.
    public typealias DetailChoice = OneOf2<FieldDef, [FieldDef]>

    /// Fill color of the marks.
    /// __Default value:__ If undefined, the default color depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `color` property.
    /// _Note:_ When using `fill` channel, `color ` channel will be ignored. To customize both fill and stroke, please use `fill` and `stroke` channels (not `fill` and `color`).
    public typealias FillChoice = OneOf2<MarkPropFieldDefWithCondition, MarkPropValueDefWithCondition>

    /// A URL to load upon mouse click.
    public typealias HrefChoice = OneOf2<FieldDefWithCondition, ValueDefWithCondition>

    /// Opacity of the marks – either can be a value or a range.
    /// __Default value:__ If undefined, the default opacity depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `opacity` property.
    public typealias OpacityChoice = OneOf2<MarkPropFieldDefWithCondition, MarkPropValueDefWithCondition>

    /// Order of the marks.
    /// - For stacked marks, this `order` channel encodes [stack order](https://vega.github.io/vega-lite/docs/stack.html#order).
    /// - For line and trail marks, this `order` channel encodes order of data points in the lines. This can be useful for creating [a connected scatterplot](https://vega.github.io/vega-lite/examples/connected_scatterplot.html).  Setting `order` to `{"value": null}` makes the line marks use the original order in the data sources.
    /// - Otherwise, this `order` channel encodes layer order of the marks.
    /// __Note__: In aggregate plots, `order` field should be `aggregate`d to avoid creating additional aggregation grouping.
    public typealias OrderChoice = OneOf3<OrderFieldDef, [OrderFieldDef], ValueDef>

    /// For `point` marks the supported values are
    /// `"circle"` (default), `"square"`, `"cross"`, `"diamond"`, `"triangle-up"`,
    /// or `"triangle-down"`, or else a custom SVG path string.
    /// For `geoshape` marks it should be a field definition of the geojson data
    /// __Default value:__ If undefined, the default shape depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#point-config)'s `shape` property.
    public typealias ShapeChoice = OneOf2<MarkPropFieldDefWithCondition, MarkPropValueDefWithCondition>

    /// Size of the mark.
    /// - For `"point"`, `"square"` and `"circle"`, – the symbol size, or pixel area of the mark.
    /// - For `"bar"` and `"tick"` – the bar and tick's size.
    /// - For `"text"` – the text's font size.
    /// - Size is unsupported for `"line"`, `"area"`, and `"rect"`. (Use `"trail"` instead of line with varying size)
    public typealias SizeChoice = OneOf2<MarkPropFieldDefWithCondition, MarkPropValueDefWithCondition>

    /// Stroke color of the marks.
    /// __Default value:__ If undefined, the default color depends on [mark config](https://vega.github.io/vega-lite/docs/config.html#mark)'s `color` property.
    /// _Note:_ When using `stroke` channel, `color ` channel will be ignored. To customize both stroke and fill, please use `stroke` and `fill` channels (not `stroke` and `color`).
    public typealias StrokeChoice = OneOf2<MarkPropFieldDefWithCondition, MarkPropValueDefWithCondition>

    /// Text of the `text` mark.
    public typealias TextChoice = OneOf2<TextFieldDefWithCondition, TextValueDefWithCondition>

    /// The tooltip text to show upon mouse hover.
    public typealias TooltipChoice = OneOf3<TextFieldDefWithCondition, TextValueDefWithCondition, [TextFieldDef]>

    /// X coordinates of the marks, or width of horizontal `"bar"` and `"area"`.
    public typealias XChoice = OneOf2<PositionFieldDef, ValueDef>

    /// X2 coordinates for ranged `"area"`, `"bar"`, `"rect"`, and  `"rule"`.
    public typealias X2Choice = OneOf2<FieldDef, ValueDef>

    /// Y coordinates of the marks, or height of vertical `"bar"` and `"area"`.
    public typealias YChoice = OneOf2<PositionFieldDef, ValueDef>

    /// Y2 coordinates for ranged `"area"`, `"bar"`, `"rect"`, and  `"rule"`.
    public typealias Y2Choice = OneOf2<FieldDef, ValueDef>
}

public enum Orient : String, Equatable, Codable {
    case horizontal
    case vertical
}

/// Definition object for a data field, its type and transformation of an encoding channel.
public struct FieldDef : Equatable, Codable {
    /// The encoded field's type of measurement (`"quantitative"`, `"temporal"`, `"ordinal"`, or `"nominal"`).
    /// It can also be a `"geojson"` type for encoding ['geoshape'](https://vega.github.io/vega-lite/docs/geoshape.html).
    public var type: `Type`
    /// Aggregation function for the field
    /// (e.g., `mean`, `sum`, `median`, `min`, `max`, `count`).
    /// __Default value:__ `undefined` (None)
    public var aggregate: Aggregate?
    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public var bin: BinChoice?
    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public var field: FieldChoice?
    /// Time unit (e.g., `year`, `yearmonth`, `month`, `hours`) for a temporal field.
    /// or [a temporal field that gets casted as ordinal](https://vega.github.io/vega-lite/docs/type.html#cast).
    /// __Default value:__ `undefined` (None)
    public var timeUnit: TimeUnit?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?

    public init(type: `Type`, aggregate: Aggregate? = .none, bin: BinChoice? = .none, field: FieldChoice? = .none, timeUnit: TimeUnit? = .none, title: Title? = .none) {
        self.type = type 
        self.aggregate = aggregate 
        self.bin = bin 
        self.field = field 
        self.timeUnit = timeUnit 
        self.title = title 
    }

    public enum CodingKeys : String, CodingKey {
        case type
        case aggregate
        case bin
        case field
        case timeUnit
        case title
    }

    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public typealias BinChoice = OneOf2<Bool, BinParams>

    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public typealias FieldChoice = OneOf2<String, RepeatRef>

    /// Definition object for a data field, its type and transformation of an encoding channel.
    public typealias Title = OneOf2<String, ExplicitNull>
}

public struct LegendResolveMap : Equatable, Codable {
    public var color: ResolveMode?
    public var fill: ResolveMode?
    public var opacity: ResolveMode?
    public var shape: ResolveMode?
    public var size: ResolveMode?
    public var stroke: ResolveMode?

    public init(color: ResolveMode? = .none, fill: ResolveMode? = .none, opacity: ResolveMode? = .none, shape: ResolveMode? = .none, size: ResolveMode? = .none, stroke: ResolveMode? = .none) {
        self.color = color 
        self.fill = fill 
        self.opacity = opacity 
        self.shape = shape 
        self.size = size 
        self.stroke = stroke 
    }

    public enum CodingKeys : String, CodingKey {
        case color
        case fill
        case opacity
        case shape
        case size
        case stroke
    }
}

public enum HorizontalAlign : String, Equatable, Codable {
    case left
    case right
    case center
}

public typealias TimeUnit = OneOf2<SingleTimeUnit, MultiTimeUnit>

public struct AggregatedFieldDef : Equatable, Codable {
    /// The aggregation operations to apply to the fields, such as sum, average or count.
    /// See the [full list of supported aggregation operations](https://vega.github.io/vega-lite/docs/aggregate.html#ops)
    /// for more information.
    public var op: AggregateOp
    /// The output field names to use for each aggregated field.
    public var `as`: String
    /// The data field for which to compute aggregate function. This is required for all aggregation operations except `"count"`.
    public var field: String?

    public init(op: AggregateOp, `as`: String, field: String? = .none) {
        self.op = op 
        self.`as` = `as` 
        self.field = field 
    }

    public enum CodingKeys : String, CodingKey {
        case op
        case `as` = "as"
        case field
    }
}

public typealias SelectionOperand = OneOf4<SelectionNot, SelectionAnd, SelectionOr, String>

public enum LocalSingleTimeUnit : String, Equatable, Codable {
    case year
    case quarter
    case month
    case day
    case date
    case hours
    case minutes
    case seconds
    case milliseconds
}

public struct ScaleResolveMap : Equatable, Codable {
    public var color: ResolveMode?
    public var fill: ResolveMode?
    public var opacity: ResolveMode?
    public var shape: ResolveMode?
    public var size: ResolveMode?
    public var stroke: ResolveMode?
    public var x: ResolveMode?
    public var y: ResolveMode?

    public init(color: ResolveMode? = .none, fill: ResolveMode? = .none, opacity: ResolveMode? = .none, shape: ResolveMode? = .none, size: ResolveMode? = .none, stroke: ResolveMode? = .none, x: ResolveMode? = .none, y: ResolveMode? = .none) {
        self.color = color 
        self.fill = fill 
        self.opacity = opacity 
        self.shape = shape 
        self.size = size 
        self.stroke = stroke 
        self.x = x 
        self.y = y 
    }

    public enum CodingKeys : String, CodingKey {
        case color
        case fill
        case opacity
        case shape
        case size
        case stroke
        case x
        case y
    }
}

public struct Config : Equatable, Codable {
    /// Area-Specific Config 
    public var area: AreaConfig?
    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public var autosize: AutosizeChoice?
    /// Axis configuration, which determines default properties for all `x` and `y` [axes](https://vega.github.io/vega-lite/docs/axis.html). For a full list of axis configuration options, please see the [corresponding section of the axis documentation](https://vega.github.io/vega-lite/docs/axis.html#config).
    public var axis: AxisConfig?
    /// Specific axis config for axes with "band" scales.
    public var axisBand: VgAxisConfig?
    /// Specific axis config for x-axis along the bottom edge of the chart.
    public var axisBottom: VgAxisConfig?
    /// Specific axis config for y-axis along the left edge of the chart.
    public var axisLeft: VgAxisConfig?
    /// Specific axis config for y-axis along the right edge of the chart.
    public var axisRight: VgAxisConfig?
    /// Specific axis config for x-axis along the top edge of the chart.
    public var axisTop: VgAxisConfig?
    /// X-axis specific config.
    public var axisX: VgAxisConfig?
    /// Y-axis specific config.
    public var axisY: VgAxisConfig?
    /// CSS color property to use as the background of visualization.
    /// __Default value:__ none (transparent)
    public var background: String?
    /// Bar-Specific Config 
    public var bar: BarConfig?
    /// Circle-Specific Config 
    public var circle: MarkConfig?
    /// Default axis and legend title for count fields.
    /// __Default value:__ `'Number of Records'`.
    public var countTitle: String?
    /// A global data store for named datasets. This is a mapping from names to inline datasets.
    /// This can be an array of objects or primitive values or a string. Arrays of primitive values are ingested as objects with a `data` property.
    public var datasets: Datasets?
    /// Defines how Vega-Lite generates title for fields.  There are three possible styles:
    /// - `"verbal"` (Default) - displays function in a verbal style (e.g., "Sum of field", "Year-month of date", "field (binned)").
    /// - `"function"` - displays function using parentheses and capitalized texts (e.g., "SUM(field)", "YEARMONTH(date)", "BIN(field)").
    /// - `"plain"` - displays only the field name without functions (e.g., "field", "date", "field").
    public var fieldTitle: FieldTitle?
    /// Geoshape-Specific Config 
    public var geoshape: MarkConfig?
    /// Defines how Vega-Lite should handle invalid values (`null` and `NaN`).
    /// - If set to `"filter"` (default), all data items with null values will be skipped (for line, trail, and area marks) or filtered (for other marks).
    /// - If `null`, all data items are included. In this case, invalid values will be interpreted as zeroes.
    public var invalidValues: InvalidValues?
    /// Legend configuration, which determines default properties for all [legends](https://vega.github.io/vega-lite/docs/legend.html). For a full list of legend configuration options, please see the [corresponding section of in the legend documentation](https://vega.github.io/vega-lite/docs/legend.html#config).
    public var legend: LegendConfig?
    /// Line-Specific Config 
    public var line: LineConfig?
    /// Mark Config 
    public var mark: MarkConfig?
    /// D3 Number format for axis labels and text tables. For example "s" for SI units. Use [D3's number format pattern](https://github.com/d3/d3-format#locale_format).
    public var numberFormat: String?
    /// The default visualization padding, in pixels, from the edge of the visualization canvas to the data rectangle.  If a number, specifies padding for all sides.
    /// If an object, the value should have the format `{"left": 5, "top": 5, "right": 5, "bottom": 5}` to specify padding for each side of the visualization.
    /// __Default value__: `5`
    public var padding: Padding?
    /// Point-Specific Config 
    public var point: MarkConfig?
    /// Projection configuration, which determines default properties for all [projections](https://vega.github.io/vega-lite/docs/projection.html). For a full list of projection configuration options, please see the [corresponding section of the projection documentation](https://vega.github.io/vega-lite/docs/projection.html#config).
    public var projection: ProjectionConfig?
    /// An object hash that defines default range arrays or schemes for using with scales.
    /// For a full list of scale range configuration options, please see the [corresponding section of the scale documentation](https://vega.github.io/vega-lite/docs/scale.html#config).
    public var range: RangeConfig?
    /// Rect-Specific Config 
    public var rect: MarkConfig?
    /// Rule-Specific Config 
    public var rule: MarkConfig?
    /// Scale configuration determines default properties for all [scales](https://vega.github.io/vega-lite/docs/scale.html). For a full list of scale configuration options, please see the [corresponding section of the scale documentation](https://vega.github.io/vega-lite/docs/scale.html#config).
    public var scale: ScaleConfig?
    /// An object hash for defining default properties for each type of selections. 
    public var selection: SelectionConfig?
    /// Square-Specific Config 
    public var square: MarkConfig?
    /// Default stack offset for stackable mark. 
    public var stack: StackOffset?
    /// An object hash that defines key-value mappings to determine default properties for marks with a given [style](https://vega.github.io/vega-lite/docs/mark.html#mark-def).  The keys represent styles names; the values have to be valid [mark configuration objects](https://vega.github.io/vega-lite/docs/mark.html#config).  
    public var style: StyleConfigIndex?
    /// Text-Specific Config 
    public var text: TextConfig?
    /// Tick-Specific Config 
    public var tick: TickConfig?
    /// Default datetime format for axis and legend labels. The format can be set directly on each axis and legend. Use [D3's time format pattern](https://github.com/d3/d3-time-format#locale_format).
    /// __Default value:__ `''` (The format will be automatically determined).
    public var timeFormat: String?
    /// Title configuration, which determines default properties for all [titles](https://vega.github.io/vega-lite/docs/title.html). For a full list of title configuration options, please see the [corresponding section of the title documentation](https://vega.github.io/vega-lite/docs/title.html#config).
    public var title: VgTitleConfig?
    /// Trail-Specific Config 
    public var trail: LineConfig?
    /// Default properties for [single view plots](https://vega.github.io/vega-lite/docs/spec.html#single). 
    public var view: ViewConfig?

    public init(area: AreaConfig? = .none, autosize: AutosizeChoice? = .none, axis: AxisConfig? = .none, axisBand: VgAxisConfig? = .none, axisBottom: VgAxisConfig? = .none, axisLeft: VgAxisConfig? = .none, axisRight: VgAxisConfig? = .none, axisTop: VgAxisConfig? = .none, axisX: VgAxisConfig? = .none, axisY: VgAxisConfig? = .none, background: String? = .none, bar: BarConfig? = .none, circle: MarkConfig? = .none, countTitle: String? = .none, datasets: Datasets? = .none, fieldTitle: FieldTitle? = .none, geoshape: MarkConfig? = .none, invalidValues: InvalidValues? = .none, legend: LegendConfig? = .none, line: LineConfig? = .none, mark: MarkConfig? = .none, numberFormat: String? = .none, padding: Padding? = .none, point: MarkConfig? = .none, projection: ProjectionConfig? = .none, range: RangeConfig? = .none, rect: MarkConfig? = .none, rule: MarkConfig? = .none, scale: ScaleConfig? = .none, selection: SelectionConfig? = .none, square: MarkConfig? = .none, stack: StackOffset? = .none, style: StyleConfigIndex? = .none, text: TextConfig? = .none, tick: TickConfig? = .none, timeFormat: String? = .none, title: VgTitleConfig? = .none, trail: LineConfig? = .none, view: ViewConfig? = .none) {
        self.area = area 
        self.autosize = autosize 
        self.axis = axis 
        self.axisBand = axisBand 
        self.axisBottom = axisBottom 
        self.axisLeft = axisLeft 
        self.axisRight = axisRight 
        self.axisTop = axisTop 
        self.axisX = axisX 
        self.axisY = axisY 
        self.background = background 
        self.bar = bar 
        self.circle = circle 
        self.countTitle = countTitle 
        self.datasets = datasets 
        self.fieldTitle = fieldTitle 
        self.geoshape = geoshape 
        self.invalidValues = invalidValues 
        self.legend = legend 
        self.line = line 
        self.mark = mark 
        self.numberFormat = numberFormat 
        self.padding = padding 
        self.point = point 
        self.projection = projection 
        self.range = range 
        self.rect = rect 
        self.rule = rule 
        self.scale = scale 
        self.selection = selection 
        self.square = square 
        self.stack = stack 
        self.style = style 
        self.text = text 
        self.tick = tick 
        self.timeFormat = timeFormat 
        self.title = title 
        self.trail = trail 
        self.view = view 
    }

    public enum CodingKeys : String, CodingKey {
        case area
        case autosize
        case axis
        case axisBand
        case axisBottom
        case axisLeft
        case axisRight
        case axisTop
        case axisX
        case axisY
        case background
        case bar
        case circle
        case countTitle
        case datasets
        case fieldTitle
        case geoshape
        case invalidValues
        case legend
        case line
        case mark
        case numberFormat
        case padding
        case point
        case projection
        case range
        case rect
        case rule
        case scale
        case selection
        case square
        case stack
        case style
        case text
        case tick
        case timeFormat
        case title
        case trail
        case view
    }

    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public typealias AutosizeChoice = OneOf2<AutosizeType, AutoSizeParams>

    /// Defines how Vega-Lite generates title for fields.  There are three possible styles:
    /// - `"verbal"` (Default) - displays function in a verbal style (e.g., "Sum of field", "Year-month of date", "field (binned)").
    /// - `"function"` - displays function using parentheses and capitalized texts (e.g., "SUM(field)", "YEARMONTH(date)", "BIN(field)").
    /// - `"plain"` - displays only the field name without functions (e.g., "field", "date", "field").
    public enum FieldTitle : String, Equatable, Codable {
        case verbal
        case functional
        case plain
    }

    public typealias InvalidValues = OneOf2<String, ExplicitNull>
}

public enum LegendOrient : String, Equatable, Codable {
    case left
    case right
    case topLeft = "top-left"
    case topRight = "top-right"
    case bottomLeft = "bottom-left"
    case bottomRight = "bottom-right"
    case none
}

public typealias RangeConfigValue = RangeConfigValueTypes.Choice
public enum RangeConfigValueTypes {

    public typealias Choice = OneOf3<[OneOf2<Double, String>], VgScheme, StepType>

    public struct StepType : Equatable, Codable {
        public var step: Double

        public init(step: Double) {
            self.step = step 
        }

        public enum CodingKeys : String, CodingKey {
            case step
        }
    }
}

public typealias SortOrder = OneOf2<VgComparatorOrder, ExplicitNull>

public struct Projection : Equatable, Codable {
    /// Sets the projection’s center to the specified center, a two-element array of longitude and latitude in degrees.
    /// __Default value:__ `[0, 0]`
    public var center: [CenterItem]?
    /// Sets the projection’s clipping circle radius to the specified angle in degrees. If `null`, switches to [antimeridian](http://bl.ocks.org/mbostock/3788999) cutting rather than small-circle clipping.
    public var clipAngle: Double?
    /// Sets the projection’s viewport clip extent to the specified bounds in pixels. The extent bounds are specified as an array `[[x0, y0], [x1, y1]]`, where `x0` is the left-side of the viewport, `y0` is the top, `x1` is the right and `y1` is the bottom. If `null`, no viewport clipping is performed.
    public var clipExtent: [ClipExtentItem]?
    public var coefficient: Double?
    public var distance: Double?
    public var fraction: Double?
    public var lobes: Double?
    public var parallel: Double?
    /// Sets the threshold for the projection’s [adaptive resampling](http://bl.ocks.org/mbostock/3795544) to the specified value in pixels. This value corresponds to the [Douglas–Peucker distance](http://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm). If precision is not specified, returns the projection’s current resampling precision which defaults to `√0.5 ≅ 0.70710…`.
    public var precision: Precision?
    public var radius: Double?
    public var ratio: Double?
    /// Sets the projection’s three-axis rotation to the specified angles, which must be a two- or three-element array of numbers [`lambda`, `phi`, `gamma`] specifying the rotation angles in degrees about each spherical axis. (These correspond to yaw, pitch and roll.)
    /// __Default value:__ `[0, 0, 0]`
    public var rotate: [RotateItem]?
    public var spacing: Double?
    public var tilt: Double?
    /// The cartographic projection to use. This value is case-insensitive, for example `"albers"` and `"Albers"` indicate the same projection type. You can find all valid projection types [in the documentation](https://vega.github.io/vega-lite/docs/projection.html#projection-types).
    /// __Default value:__ `mercator`
    public var type: ProjectionType?

    public init(center: [CenterItem]? = .none, clipAngle: Double? = .none, clipExtent: [ClipExtentItem]? = .none, coefficient: Double? = .none, distance: Double? = .none, fraction: Double? = .none, lobes: Double? = .none, parallel: Double? = .none, precision: Precision? = .none, radius: Double? = .none, ratio: Double? = .none, rotate: [RotateItem]? = .none, spacing: Double? = .none, tilt: Double? = .none, type: ProjectionType? = .none) {
        self.center = center 
        self.clipAngle = clipAngle 
        self.clipExtent = clipExtent 
        self.coefficient = coefficient 
        self.distance = distance 
        self.fraction = fraction 
        self.lobes = lobes 
        self.parallel = parallel 
        self.precision = precision 
        self.radius = radius 
        self.ratio = ratio 
        self.rotate = rotate 
        self.spacing = spacing 
        self.tilt = tilt 
        self.type = type 
    }

    public enum CodingKeys : String, CodingKey {
        case center
        case clipAngle
        case clipExtent
        case coefficient
        case distance
        case fraction
        case lobes
        case parallel
        case precision
        case radius
        case ratio
        case rotate
        case spacing
        case tilt
        case type
    }

    public typealias CenterItem = Double

    public typealias ClipExtentItem = [Double]

    /// Sets the threshold for the projection’s [adaptive resampling](http://bl.ocks.org/mbostock/3795544) to the specified value in pixels. This value corresponds to the [Douglas–Peucker distance](http://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm). If precision is not specified, returns the projection’s current resampling precision which defaults to `√0.5 ≅ 0.70710…`.
    public struct Precision : Equatable, Codable {
        /// Returns the length of a String object. 
        public var length: Double
        public var additionalProperties: Dictionary<String, Bric>

        public init(length: Double, additionalProperties: Dictionary<String, Bric> = [:]) {
            self.length = length 
            self.additionalProperties = additionalProperties 
        }

        public enum CodingKeys : String, CodingKey {
            case length
            case additionalProperties = ""
        }
    }

    public typealias RotateItem = Double
}

public typealias Aggregate = AggregateOp

public struct ViewConfig : Equatable, Codable {
    /// Whether the view should be clipped.
    public var clip: Bool?
    /// The fill color.
    /// __Default value:__ (none)
    public var fill: String?
    /// The fill opacity (value between [0,1]).
    /// __Default value:__ (none)
    public var fillOpacity: Double?
    /// The default height of the single plot or each plot in a trellis plot when the visualization has a continuous (non-ordinal) y-scale with `rangeStep` = `null`.
    /// __Default value:__ `200`
    public var height: Double?
    /// The stroke color.
    /// __Default value:__ (none)
    public var stroke: String?
    /// An array of alternating stroke, space lengths for creating dashed or dotted lines.
    /// __Default value:__ (none)
    public var strokeDash: [StrokeDashItem]?
    /// The offset (in pixels) into which to begin drawing with the stroke dash array.
    /// __Default value:__ (none)
    public var strokeDashOffset: Double?
    /// The stroke opacity (value between [0,1]).
    /// __Default value:__ (none)
    public var strokeOpacity: Double?
    /// The stroke width, in pixels.
    /// __Default value:__ (none)
    public var strokeWidth: Double?
    /// The default width of the single plot or each plot in a trellis plot when the visualization has a continuous (non-ordinal) x-scale or ordinal x-scale with `rangeStep` = `null`.
    /// __Default value:__ `200`
    public var width: Double?

    public init(clip: Bool? = .none, fill: String? = .none, fillOpacity: Double? = .none, height: Double? = .none, stroke: String? = .none, strokeDash: [StrokeDashItem]? = .none, strokeDashOffset: Double? = .none, strokeOpacity: Double? = .none, strokeWidth: Double? = .none, width: Double? = .none) {
        self.clip = clip 
        self.fill = fill 
        self.fillOpacity = fillOpacity 
        self.height = height 
        self.stroke = stroke 
        self.strokeDash = strokeDash 
        self.strokeDashOffset = strokeDashOffset 
        self.strokeOpacity = strokeOpacity 
        self.strokeWidth = strokeWidth 
        self.width = width 
    }

    public enum CodingKeys : String, CodingKey {
        case clip
        case fill
        case fillOpacity
        case height
        case stroke
        case strokeDash
        case strokeDashOffset
        case strokeOpacity
        case strokeWidth
        case width
    }

    public typealias StrokeDashItem = Double
}

/// All types of primitive marks.
public enum Mark : String, Equatable, Codable {
    case area
    case bar
    case line
    case trail
    case point
    case text
    case tick
    case rect
    case rule
    case circle
    case square
    case geoshape
}

public struct OrderFieldDef : Equatable, Codable {
    /// The encoded field's type of measurement (`"quantitative"`, `"temporal"`, `"ordinal"`, or `"nominal"`).
    /// It can also be a `"geojson"` type for encoding ['geoshape'](https://vega.github.io/vega-lite/docs/geoshape.html).
    public var type: `Type`
    /// Aggregation function for the field
    /// (e.g., `mean`, `sum`, `median`, `min`, `max`, `count`).
    /// __Default value:__ `undefined` (None)
    public var aggregate: Aggregate?
    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public var bin: BinChoice?
    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public var field: FieldChoice?
    /// The sort order. One of `"ascending"` (default) or `"descending"`.
    public var sort: SortOrder?
    /// Time unit (e.g., `year`, `yearmonth`, `month`, `hours`) for a temporal field.
    /// or [a temporal field that gets casted as ordinal](https://vega.github.io/vega-lite/docs/type.html#cast).
    /// __Default value:__ `undefined` (None)
    public var timeUnit: TimeUnit?
    /// A title for the field. If `null`, the title will be removed.
    /// __Default value:__  derived from the field's name and transformation function (`aggregate`, `bin` and `timeUnit`).  If the field has an aggregate function, the function is displayed as part of the title (e.g., `"Sum of Profit"`). If the field is binned or has a time unit applied, the applied function is shown in parentheses (e.g., `"Profit (binned)"`, `"Transaction Date (year-month)"`).  Otherwise, the title is simply the field name.
    /// __Notes__:
    /// 1) You can customize the default field title format by providing the [`fieldTitle` property in the [config](https://vega.github.io/vega-lite/docs/config.html) or [`fieldTitle` function via the `compile` function's options](https://vega.github.io/vega-lite/docs/compile.html#field-title).
    /// 2) If both field definition's `title` and axis, header, or legend `title` are defined, axis/header/legend title will be used.
    public var title: Title?

    public init(type: `Type`, aggregate: Aggregate? = .none, bin: BinChoice? = .none, field: FieldChoice? = .none, sort: SortOrder? = .none, timeUnit: TimeUnit? = .none, title: Title? = .none) {
        self.type = type 
        self.aggregate = aggregate 
        self.bin = bin 
        self.field = field 
        self.sort = sort 
        self.timeUnit = timeUnit 
        self.title = title 
    }

    public enum CodingKeys : String, CodingKey {
        case type
        case aggregate
        case bin
        case field
        case sort
        case timeUnit
        case title
    }

    /// A flag for binning a `quantitative` field, or [an object defining binning parameters](https://vega.github.io/vega-lite/docs/bin.html#params).
    /// If `true`, default [binning parameters](https://vega.github.io/vega-lite/docs/bin.html) will be applied.
    /// __Default value:__ `false`
    public typealias BinChoice = OneOf2<Bool, BinParams>

    /// __Required.__ A string defining the name of the field from which to pull a data value
    /// or an object defining iterated values from the [`repeat`](https://vega.github.io/vega-lite/docs/repeat.html) operator.
    /// __Note:__ Dots (`.`) and brackets (`[` and `]`) can be used to access nested objects (e.g., `"field": "foo.bar"` and `"field": "foo['bar']"`).
    /// If field names contain dots or brackets but are not nested, you can use `\\` to escape dots and brackets (e.g., `"a\\.b"` and `"a\\[0\\]"`).
    /// See more details about escaping in the [field documentation](https://vega.github.io/vega-lite/docs/field.html).
    /// __Note:__ `field` is not required if `aggregate` is `count`.
    public typealias FieldChoice = OneOf2<String, RepeatRef>

    public typealias Title = OneOf2<String, ExplicitNull>
}

public struct TopLevelHConcatSpec : Equatable, Codable {
    /// A list of views that should be concatenated and put into a row.
    public var hconcat: [Spec]
    /// URL to [JSON schema](http://json-schema.org/) for a Vega-Lite specification. Unless you have a reason to change this, use `https://vega.github.io/schema/vega-lite/v2.json`. Setting the `$schema` property allows automatic validation and autocomplete in editors that support JSON schema.
    public var schema: String?
    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public var autosize: AutosizeChoice?
    /// CSS color property to use as the background of visualization.
    /// __Default value:__ none (transparent)
    public var background: String?
    /// Vega-Lite configuration object.  This property can only be defined at the top-level of a specification.
    public var config: Config?
    /// An object describing the data source
    public var data: Data?
    /// A global data store for named datasets. This is a mapping from names to inline datasets.
    /// This can be an array of objects or primitive values or a string. Arrays of primitive values are ingested as objects with a `data` property.
    public var datasets: Datasets?
    /// Description of this mark for commenting purpose.
    public var description: String?
    /// Name of the visualization for later reference.
    public var name: String?
    /// The default visualization padding, in pixels, from the edge of the visualization canvas to the data rectangle.  If a number, specifies padding for all sides.
    /// If an object, the value should have the format `{"left": 5, "top": 5, "right": 5, "bottom": 5}` to specify padding for each side of the visualization.
    /// __Default value__: `5`
    public var padding: Padding?
    /// Scale, axis, and legend resolutions for horizontally concatenated charts.
    public var resolve: Resolve?
    /// Title for the plot.
    public var title: TitleChoice?
    /// An array of data transformations such as filter and new field calculation.
    public var transform: [Transform]?

    public init(hconcat: [Spec] = [], schema: String? = .none, autosize: AutosizeChoice? = .none, background: String? = .none, config: Config? = .none, data: Data? = .none, datasets: Datasets? = .none, description: String? = .none, name: String? = .none, padding: Padding? = .none, resolve: Resolve? = .none, title: TitleChoice? = .none, transform: [Transform]? = .none) {
        self.hconcat = hconcat 
        self.schema = schema 
        self.autosize = autosize 
        self.background = background 
        self.config = config 
        self.data = data 
        self.datasets = datasets 
        self.description = description 
        self.name = name 
        self.padding = padding 
        self.resolve = resolve 
        self.title = title 
        self.transform = transform 
    }

    public enum CodingKeys : String, CodingKey {
        case hconcat
        case schema = "$schema"
        case autosize
        case background
        case config
        case data
        case datasets
        case description
        case name
        case padding
        case resolve
        case title
        case transform
    }

    /// Sets how the visualization size should be determined. If a string, should be one of `"pad"`, `"fit"` or `"none"`.
    /// Object values can additionally specify parameters for content sizing and automatic resizing.
    /// `"fit"` is only supported for single and layered views that don't use `rangeStep`.
    /// __Default value__: `pad`
    public typealias AutosizeChoice = OneOf2<AutosizeType, AutoSizeParams>

    /// Title for the plot.
    public typealias TitleChoice = OneOf2<String, TitleParams>
}

public enum SingleDefChannel : String, Equatable, Codable {
    case x
    case y
    case x2
    case y2
    case longitude
    case latitude
    case longitude2
    case latitude2
    case row
    case column
    case color
    case fill
    case stroke
    case size
    case shape
    case opacity
    case text
    case tooltip
    case href
    case key
}

public struct VgRangeBinding : Equatable, Codable {
    public var input: Input
    public var element: String?
    public var max: Double?
    public var min: Double?
    public var step: Double?

    public init(input: Input = .range, element: String? = .none, max: Double? = .none, min: Double? = .none, step: Double? = .none) {
        self.input = input 
        self.element = element 
        self.max = max 
        self.min = min 
        self.step = step 
    }

    public enum CodingKeys : String, CodingKey {
        case input
        case element
        case max
        case min
        case step
    }

    public enum Input : String, Equatable, Codable {
        case range
    }
}

public struct BarConfig : Equatable, Codable {
    /// The horizontal alignment of the text. One of `"left"`, `"right"`, `"center"`.
    public var align: HorizontalAlign?
    /// The rotation angle of the text, in degrees.
    public var angle: Double?
    /// The vertical alignment of the text. One of `"top"`, `"middle"`, `"bottom"`.
    /// __Default value:__ `"middle"`
    public var baseline: VerticalAlign?
    /// Offset between bars for binned field.  Ideal value for this is either 0 (Preferred by statisticians) or 1 (Vega-Lite Default, D3 example style).
    /// __Default value:__ `1`
    public var binSpacing: Double?
    /// Default color.  Note that `fill` and `stroke` have higher precedence than `color` and will override `color`.
    /// __Default value:__ <span style="color: #4682b4;">&#9632;</span> `"#4682b4"`
    /// __Note:__ This property cannot be used in a [style config](https://vega.github.io/vega-lite/docs/mark.html#style-config).
    public var color: String?
    /// The default size of the bars on continuous scales.
    /// __Default value:__ `5`
    public var continuousBandSize: Double?
    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public var cursor: Cursor?
    /// The size of the bars.  If unspecified, the default size is  `bandSize-1`,
    /// which provides 1 pixel offset between bars.
    public var discreteBandSize: Double?
    /// The horizontal offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dx: Double?
    /// The vertical offset, in pixels, between the text label and its anchor point. The offset is applied after rotation by the _angle_ property.
    public var dy: Double?
    /// Default Fill Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var fill: String?
    /// The fill opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var fillOpacity: Double?
    /// Whether the mark's color should be used as fill color instead of stroke color.
    /// __Default value:__ `true` for all marks except `point` and `false` for `point`.
    /// __Applicable for:__ `bar`, `point`, `circle`, `square`, and `area` marks.
    /// __Note:__ This property cannot be used in a [style config](https://vega.github.io/vega-lite/docs/mark.html#style-config).
    public var filled: Bool?
    /// The typeface to set the text in (e.g., `"Helvetica Neue"`).
    public var font: String?
    /// The font size, in pixels.
    public var fontSize: Double?
    /// The font style (e.g., `"italic"`).
    public var fontStyle: FontStyle?
    /// The font weight.
    /// This can be either a string (e.g `"bold"`, `"normal"`) or a number (`100`, `200`, `300`, ..., `900` where `"normal"` = `400` and `"bold"` = `700`).
    public var fontWeight: FontWeight?
    /// A URL to load upon mouse click. If defined, the mark acts as a hyperlink.
    public var href: String?
    /// The line interpolation method to use for line and area marks. One of the following:
    /// - `"linear"`: piecewise linear segments, as in a polyline.
    /// - `"linear-closed"`: close the linear segments to form a polygon.
    /// - `"step"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"step-before"`: alternate between vertical and horizontal segments, as in a step function.
    /// - `"step-after"`: alternate between horizontal and vertical segments, as in a step function.
    /// - `"basis"`: a B-spline, with control point duplication on the ends.
    /// - `"basis-open"`: an open B-spline; may not intersect the start or end.
    /// - `"basis-closed"`: a closed B-spline, as in a loop.
    /// - `"cardinal"`: a Cardinal spline, with control point duplication on the ends.
    /// - `"cardinal-open"`: an open Cardinal spline; may not intersect the start or end, but will intersect other control points.
    /// - `"cardinal-closed"`: a closed Cardinal spline, as in a loop.
    /// - `"bundle"`: equivalent to basis, except the tension parameter is used to straighten the spline.
    /// - `"monotone"`: cubic interpolation that preserves monotonicity in y.
    public var interpolate: Interpolate?
    /// The maximum length of the text mark in pixels (default 0, indicating no limit). The text value will be automatically truncated if the rendered size exceeds the limit.
    public var limit: Double?
    /// The overall opacity (value between [0,1]).
    /// __Default value:__ `0.7` for non-aggregate plots with `point`, `tick`, `circle`, or `square` marks or layered `bar` charts and `1` otherwise.
    public var opacity: Double?
    /// The orientation of a non-stacked bar, tick, area, and line charts.
    /// The value is either horizontal (default) or vertical.
    /// - For bar, rule and tick, this determines whether the size of the bar and tick
    /// should be applied to x or y dimension.
    /// - For area, this property determines the orient property of the Vega output.
    /// - For line and trail marks, this property determines the sort order of the points in the line
    /// if `config.sortLineBy` is not specified.
    /// For stacked charts, this is always determined by the orientation of the stack;
    /// therefore explicitly specified value will be ignored.
    public var orient: Orient?
    /// Polar coordinate radial offset, in pixels, of the text label from the origin determined by the `x` and `y` properties.
    public var radius: Double?
    /// The default symbol shape to use. One of: `"circle"` (default), `"square"`, `"cross"`, `"diamond"`, `"triangle-up"`, or `"triangle-down"`, or a custom SVG path.
    /// __Default value:__ `"circle"`
    public var shape: String?
    /// The pixel area each the point/circle/square.
    /// For example: in the case of circles, the radius is determined in part by the square root of the size value.
    /// __Default value:__ `30`
    public var size: Double?
    /// Default Stroke Color.  This has higher precedence than `config.color`
    /// __Default value:__ (None)
    public var stroke: String?
    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public var strokeCap: StrokeCap?
    /// An array of alternating stroke, space lengths for creating dashed or dotted lines.
    public var strokeDash: [StrokeDashItem]?
    /// The offset (in pixels) into which to begin drawing with the stroke dash array.
    public var strokeDashOffset: Double?
    /// The stroke opacity (value between [0,1]).
    /// __Default value:__ `1`
    public var strokeOpacity: Double?
    /// The stroke width, in pixels.
    public var strokeWidth: Double?
    /// Depending on the interpolation type, sets the tension parameter (for line and area marks).
    public var tension: Double?
    /// Placeholder text if the `text` channel is not specified
    public var text: String?
    /// Polar coordinate angle, in radians, of the text label from the origin determined by the `x` and `y` properties. Values for `theta` follow the same convention of `arc` mark `startAngle` and `endAngle` properties: angles are measured in radians, with `0` indicating "north".
    public var theta: Double?

    public init(align: HorizontalAlign? = .none, angle: Double? = .none, baseline: VerticalAlign? = .none, binSpacing: Double? = .none, color: String? = .none, continuousBandSize: Double? = .none, cursor: Cursor? = .none, discreteBandSize: Double? = .none, dx: Double? = .none, dy: Double? = .none, fill: String? = .none, fillOpacity: Double? = .none, filled: Bool? = .none, font: String? = .none, fontSize: Double? = .none, fontStyle: FontStyle? = .none, fontWeight: FontWeight? = .none, href: String? = .none, interpolate: Interpolate? = .none, limit: Double? = .none, opacity: Double? = .none, orient: Orient? = .none, radius: Double? = .none, shape: String? = .none, size: Double? = .none, stroke: String? = .none, strokeCap: StrokeCap? = .none, strokeDash: [StrokeDashItem]? = .none, strokeDashOffset: Double? = .none, strokeOpacity: Double? = .none, strokeWidth: Double? = .none, tension: Double? = .none, text: String? = .none, theta: Double? = .none) {
        self.align = align 
        self.angle = angle 
        self.baseline = baseline 
        self.binSpacing = binSpacing 
        self.color = color 
        self.continuousBandSize = continuousBandSize 
        self.cursor = cursor 
        self.discreteBandSize = discreteBandSize 
        self.dx = dx 
        self.dy = dy 
        self.fill = fill 
        self.fillOpacity = fillOpacity 
        self.filled = filled 
        self.font = font 
        self.fontSize = fontSize 
        self.fontStyle = fontStyle 
        self.fontWeight = fontWeight 
        self.href = href 
        self.interpolate = interpolate 
        self.limit = limit 
        self.opacity = opacity 
        self.orient = orient 
        self.radius = radius 
        self.shape = shape 
        self.size = size 
        self.stroke = stroke 
        self.strokeCap = strokeCap 
        self.strokeDash = strokeDash 
        self.strokeDashOffset = strokeDashOffset 
        self.strokeOpacity = strokeOpacity 
        self.strokeWidth = strokeWidth 
        self.tension = tension 
        self.text = text 
        self.theta = theta 
    }

    public enum CodingKeys : String, CodingKey {
        case align
        case angle
        case baseline
        case binSpacing
        case color
        case continuousBandSize
        case cursor
        case discreteBandSize
        case dx
        case dy
        case fill
        case fillOpacity
        case filled
        case font
        case fontSize
        case fontStyle
        case fontWeight
        case href
        case interpolate
        case limit
        case opacity
        case orient
        case radius
        case shape
        case size
        case stroke
        case strokeCap
        case strokeDash
        case strokeDashOffset
        case strokeOpacity
        case strokeWidth
        case tension
        case text
        case theta
    }

    /// The mouse cursor used over the mark. Any valid [CSS cursor type](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Values) can be used.
    public enum Cursor : String, Equatable, Codable {
        case auto
        case `default` = "default"
        case none
        case contextMenu = "context-menu"
        case help
        case pointer
        case progress
        case wait
        case cell
        case crosshair
        case text
        case verticalText = "vertical-text"
        case alias
        case copy
        case move
        case noDrop = "no-drop"
        case notAllowed = "not-allowed"
        case eResize = "e-resize"
        case nResize = "n-resize"
        case neResize = "ne-resize"
        case nwResize = "nw-resize"
        case sResize = "s-resize"
        case seResize = "se-resize"
        case swResize = "sw-resize"
        case wResize = "w-resize"
        case ewResize = "ew-resize"
        case nsResize = "ns-resize"
        case neswResize = "nesw-resize"
        case nwseResize = "nwse-resize"
        case colResize = "col-resize"
        case rowResize = "row-resize"
        case allScroll = "all-scroll"
        case zoomIn = "zoom-in"
        case zoomOut = "zoom-out"
        case grab
        case grabbing
    }

    /// The stroke cap for line ending style. One of `"butt"`, `"round"`, or `"square"`.
    /// __Default value:__ `"square"`
    public enum StrokeCap : String, Equatable, Codable {
        case butt
        case round
        case square
    }

    public typealias StrokeDashItem = Double
}

public struct FieldRangePredicate : Equatable, Codable {
    /// Field to be filtered.
    public var field: String
    /// An array of inclusive minimum and maximum values
    /// for a field value of a data item to be included in the filtered data.
    public var range: [RangeItemChoice]
    /// Time unit for the field to be filtered.
    public var timeUnit: TimeUnit?

    public init(field: String, range: [RangeItemChoice] = [], timeUnit: TimeUnit? = .none) {
        self.field = field 
        self.range = range 
        self.timeUnit = timeUnit 
    }

    public enum CodingKeys : String, CodingKey {
        case field
        case range
        case timeUnit
    }

    public typealias RangeItemChoice = OneOf3<Double, DateTime, ExplicitNull>
}

/// Reference to a repeated value.
public struct RepeatRef : Equatable, Codable {
    public var `repeat`: Repeat

    public init(`repeat`: Repeat) {
        self.`repeat` = `repeat` 
    }

    public enum CodingKeys : String, CodingKey {
        case `repeat` = "repeat"
    }

    public enum Repeat : String, Equatable, Codable {
        case row
        case column
    }
}

public struct AutoSizeParams : Equatable, Codable {
    /// Determines how size calculation should be performed, one of `"content"` or `"padding"`. The default setting (`"content"`) interprets the width and height settings as the data rectangle (plotting) dimensions, to which padding is then added. In contrast, the `"padding"` setting includes the padding within the view size calculations, such that the width and height settings indicate the **total** intended size of the view.
    /// __Default value__: `"content"`
    public var contains: Contains?
    /// A boolean flag indicating if autosize layout should be re-calculated on every view update.
    /// __Default value__: `false`
    public var resize: Bool?
    /// The sizing format type. One of `"pad"`, `"fit"` or `"none"`. See the [autosize type](https://vega.github.io/vega-lite/docs/size.html#autosize) documentation for descriptions of each.
    /// __Default value__: `"pad"`
    public var type: AutosizeType?

    public init(contains: Contains? = .none, resize: Bool? = .none, type: AutosizeType? = .none) {
        self.contains = contains 
        self.resize = resize 
        self.type = type 
    }

    public enum CodingKeys : String, CodingKey {
        case contains
        case resize
        case type
    }

    /// Determines how size calculation should be performed, one of `"content"` or `"padding"`. The default setting (`"content"`) interprets the width and height settings as the data rectangle (plotting) dimensions, to which padding is then added. In contrast, the `"padding"` setting includes the padding within the view size calculations, such that the width and height settings indicate the **total** intended size of the view.
    /// __Default value__: `"content"`
    public enum Contains : String, Equatable, Codable {
        case content
        case padding
    }
}

public struct LegendConfig : Equatable, Codable {
    /// Corner radius for the full legend.
    public var cornerRadius: Double?
    /// Padding (in pixels) between legend entries in a symbol legend.
    public var entryPadding: Double?
    /// Background fill color for the full legend.
    public var fillColor: String?
    /// The height of the gradient, in pixels.
    public var gradientHeight: Double?
    /// Text baseline for color ramp gradient labels.
    public var gradientLabelBaseline: String?
    /// The maximum allowed length in pixels of color ramp gradient labels.
    public var gradientLabelLimit: Double?
    /// Vertical offset in pixels for color ramp gradient labels.
    public var gradientLabelOffset: Double?
    /// The color of the gradient stroke, can be in hex color code or regular color name.
    public var gradientStrokeColor: String?
    /// The width of the gradient stroke, in pixels.
    public var gradientStrokeWidth: Double?
    /// The width of the gradient, in pixels.
    public var gradientWidth: Double?
    /// The alignment of the legend label, can be left, middle or right.
    public var labelAlign: String?
    /// The position of the baseline of legend label, can be top, middle or bottom.
    public var labelBaseline: String?
    /// The color of the legend label, can be in hex color code or regular color name.
    public var labelColor: String?
    /// The font of the legend label.
    public var labelFont: String?
    /// The font size of legend label.
    /// __Default value:__ `10`.
    public var labelFontSize: Double?
    /// Maximum allowed pixel width of axis tick labels.
    public var labelLimit: Double?
    /// The offset of the legend label.
    public var labelOffset: Double?
    /// The offset, in pixels, by which to displace the legend from the edge of the enclosing group or data rectangle.
    /// __Default value:__  `0`
    public var offset: Double?
    /// The orientation of the legend, which determines how the legend is positioned within the scene. One of "left", "right", "top-left", "top-right", "bottom-left", "bottom-right", "none".
    /// __Default value:__ `"right"`
    public var orient: LegendOrient?
    /// The padding, in pixels, between the legend and axis.
    public var padding: Double?
    /// Whether month names and weekday names should be abbreviated.
    /// __Default value:__  `false`
    public var shortTimeLabels: Bool?
    /// Border stroke color for the full legend.
    public var strokeColor: String?
    /// Border stroke dash pattern for the full legend.
    public var strokeDash: [StrokeDashItem]?
    /// Border stroke width for the full legend.
    public var strokeWidth: Double?
    /// The color of the legend symbol,
    public var symbolColor: String?
    /// The size of the legend symbol, in pixels.
    public var symbolSize: Double?
    /// The width of the symbol's stroke.
    public var symbolStrokeWidth: Double?
    /// Default shape type (such as "circle") for legend symbols.
    public var symbolType: String?
    /// Horizontal text alignment for legend titles.
    public var titleAlign: String?
    /// Vertical text baseline for legend titles.
    public var titleBaseline: String?
    /// The color of the legend title, can be in hex color code or regular color name.
    public var titleColor: String?
    /// The font of the legend title.
    public var titleFont: String?
    /// The font size of the legend title.
    public var titleFontSize: Double?
    /// The font weight of the legend title.
    /// This can be either a string (e.g `"bold"`, `"normal"`) or a number (`100`, `200`, `300`, ..., `900` where `"normal"` = `400` and `"bold"` = `700`).
    public var titleFontWeight: FontWeight?
    /// Maximum allowed pixel width of axis titles.
    public var titleLimit: Double?
    /// The padding, in pixels, between title and legend.
    public var titlePadding: Double?

    public init(cornerRadius: Double? = .none, entryPadding: Double? = .none, fillColor: String? = .none, gradientHeight: Double? = .none, gradientLabelBaseline: String? = .none, gradientLabelLimit: Double? = .none, gradientLabelOffset: Double? = .none, gradientStrokeColor: String? = .none, gradientStrokeWidth: Double? = .none, gradientWidth: Double? = .none, labelAlign: String? = .none, labelBaseline: String? = .none, labelColor: String? = .none, labelFont: String? = .none, labelFontSize: Double? = .none, labelLimit: Double? = .none, labelOffset: Double? = .none, offset: Double? = .none, orient: LegendOrient? = .none, padding: Double? = .none, shortTimeLabels: Bool? = .none, strokeColor: String? = .none, strokeDash: [StrokeDashItem]? = .none, strokeWidth: Double? = .none, symbolColor: String? = .none, symbolSize: Double? = .none, symbolStrokeWidth: Double? = .none, symbolType: String? = .none, titleAlign: String? = .none, titleBaseline: String? = .none, titleColor: String? = .none, titleFont: String? = .none, titleFontSize: Double? = .none, titleFontWeight: FontWeight? = .none, titleLimit: Double? = .none, titlePadding: Double? = .none) {
        self.cornerRadius = cornerRadius 
        self.entryPadding = entryPadding 
        self.fillColor = fillColor 
        self.gradientHeight = gradientHeight 
        self.gradientLabelBaseline = gradientLabelBaseline 
        self.gradientLabelLimit = gradientLabelLimit 
        self.gradientLabelOffset = gradientLabelOffset 
        self.gradientStrokeColor = gradientStrokeColor 
        self.gradientStrokeWidth = gradientStrokeWidth 
        self.gradientWidth = gradientWidth 
        self.labelAlign = labelAlign 
        self.labelBaseline = labelBaseline 
        self.labelColor = labelColor 
        self.labelFont = labelFont 
        self.labelFontSize = labelFontSize 
        self.labelLimit = labelLimit 
        self.labelOffset = labelOffset 
        self.offset = offset 
        self.orient = orient 
        self.padding = padding 
        self.shortTimeLabels = shortTimeLabels 
        self.strokeColor = strokeColor 
        self.strokeDash = strokeDash 
        self.strokeWidth = strokeWidth 
        self.symbolColor = symbolColor 
        self.symbolSize = symbolSize 
        self.symbolStrokeWidth = symbolStrokeWidth 
        self.symbolType = symbolType 
        self.titleAlign = titleAlign 
        self.titleBaseline = titleBaseline 
        self.titleColor = titleColor 
        self.titleFont = titleFont 
        self.titleFontSize = titleFontSize 
        self.titleFontWeight = titleFontWeight 
        self.titleLimit = titleLimit 
        self.titlePadding = titlePadding 
    }

    public enum CodingKeys : String, CodingKey {
        case cornerRadius
        case entryPadding
        case fillColor
        case gradientHeight
        case gradientLabelBaseline
        case gradientLabelLimit
        case gradientLabelOffset
        case gradientStrokeColor
        case gradientStrokeWidth
        case gradientWidth
        case labelAlign
        case labelBaseline
        case labelColor
        case labelFont
        case labelFontSize
        case labelLimit
        case labelOffset
        case offset
        case orient
        case padding
        case shortTimeLabels
        case strokeColor
        case strokeDash
        case strokeWidth
        case symbolColor
        case symbolSize
        case symbolStrokeWidth
        case symbolType
        case titleAlign
        case titleBaseline
        case titleColor
        case titleFont
        case titleFontSize
        case titleFontWeight
        case titleLimit
        case titlePadding
    }

    public typealias StrokeDashItem = Double
}

public enum AutosizeType : String, Equatable, Codable {
    case pad
    case fit
    case none
}

public enum VgComparatorOrder : String, Equatable, Codable {
    case ascending
    case descending
}

public typealias ConditionalTextFieldDef = OneOf2<ConditionalPredicateTextFieldDef, ConditionalSelectionTextFieldDef>

public enum SelectionResolution : String, Equatable, Codable {
    case global
    case union
    case intersect
}

public struct FieldGTPredicate : Equatable, Codable {
    /// Field to be filtered.
    public var field: String
    /// The value that the field should be greater than.
    public var gt: GtChoice
    /// Time unit for the field to be filtered.
    public var timeUnit: TimeUnit?

    public init(field: String, gt: GtChoice, timeUnit: TimeUnit? = .none) {
        self.field = field 
        self.gt = gt 
        self.timeUnit = timeUnit 
    }

    public enum CodingKeys : String, CodingKey {
        case field
        case gt
        case timeUnit
    }

    /// The value that the field should be greater than.
    public typealias GtChoice = OneOf3<String, Double, DateTime>
}
