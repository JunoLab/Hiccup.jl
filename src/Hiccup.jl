module Hiccup

using Lazy, MacroTools, Compat

export Node, tag, @tags, @exporttags

# Void elements; not allowed to contain content
# See: http://www.w3.org/TR/html5/syntax.html#void-elements
const VOID_ELEMENTS = Set([:area, :base, :br, :col, :embed, :hr, :img, :input,
  :keygen, :link, :meta, :param, :source, :track, :wbr])

# Basic Types

type Node{tag}
  attrs::Dict{Any, Any}
  children::Vector{Any}
end

tag{T}(node::Node{T}) = T
attrs(node::Node) = node.attrs
children(node::Node) = node.children

isvoid(tag::Symbol) = tag in VOID_ELEMENTS
isvoid(node::Node) = isvoid(tag(node))

function Node(tag::Symbol, attrs::Dict = Dict(), content::AbstractVector = c(); kws...)
  if isvoid(tag) && !isempty(content)
    throw(ArgumentError("Void tag <$tag> cannot have content."))
  end
  Node{tag}(isempty(kws) ? attrs : merge(attrs, Dict([kws...])), content)
end

Node(tag::Symbol, attrs::Associative, content; kws...) =
  Node(tag, attrs, c(content); kws...)

Node(tag::Symbol, content; kws...) =
  Node(tag, Dict(), content; kws...)

Node(tag::Symbol, content::Node...) = Node(tag, collect(content))

# CSS selector parsing

function cssparse(s)
  trimfirst(s) = s[2:end]
  attrs = Dict()
  id = match(r"#-?[_a-zA-Z][_a-zA-Z0-9-]*", s)
  id == nothing || (attrs[:id] = trimfirst(id.match))
  classes = matchall(r"\.-?[_a-zA-Z][_a-zA-Z0-9-]*", s)
  isempty(classes) || (attrs[:class] = map(trimfirst, classes))
  return attrs
end

Node(tag::Symbol, selector::AbstractString, props::Dict, args...; kws...) =
  Node(tag, merge!(cssparse(selector), props), args...; kws...)

Node(tag::Symbol, selector::AbstractString, content, args...; kws...) =
  Node(tag, cssparse(selector), content, args...; kws...)

# Rendering

export htmlescape

attrstring(xs::Vector) = join(xs, " ")
attrstring(x) = string(x)
attrstring(d::Dict) = @as _ d map(t->"$(t[1])=\"$(attrstring(t[2]))\"", _) join(_, " ")

htmlescape(s::AbstractString) =
    @> s replace(r"&(?!(\w+|\#\d+);)", "&amp;") replace("<", "&lt;") replace(">", "&gt;") replace("\"", "&quot;")

render(io::IO, s::AbstractString) = print(io, htmlescape(s))

function render(io::IO, node::Node)
  print(io, "<", tag(node))
  isempty(attrs(node)) || print(io, " ", attrstring(attrs(node)))
  if isvoid(node)
    print(io, " />")
  else
    print(io, ">")
    render(io, children(node))

    print(io, "</", tag(node), ">")
  end
end

function render(io::IO, xs::Vector)
  for x in xs
    render(io, x)
  end
end

render(io::IO, x) = writemime(io, MIME"text/html"(), x)

Base.writemime(io::IO, ::MIME"text/html", node::Node) = render(io, node)

Base.show(io::IO, node::Node) = render(io, node)

Node(tag::Symbol, io::IO, args...) = render(io, Node(tag, args...))

# Specific elements

tags(t) = :(($t)(args...; kws...) = Node($(Expr(:quote, t)), args...; kws...))

macro tags(ts)
  isexpr(ts, Symbol) && (ts = Expr(:tuple, ts))
  @assert isexpr(ts, :tuple)
  quote
    $([tags(t) for t in ts.args]...)
  end |> esc
end

macro exporttags(ts)
  quote
    @tags $(esc(ts))
    $(Expr(:export, (isexpr(ts, Symbol) ? [ts] : ts.args)...))
  end
end

@exporttags div, span, a,
            h1, h2, h3,
            html, head, body,
            pre, code,
            img, style,
            ol, ul, li, table, tr, td,
            strong

end # module
