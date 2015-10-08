module Hiccup

using Lazy, MacroTools

export Node, tag, @tags, @exporttags

# Basic Types

type Node{tag}
  attrs::Dict{Any, Any}
  children::Vector{Any}
end

tag{T}(node::Node{T}) = T
attrs(node::Node) = node.attrs
children(node::Node) = node.children

Node(tag::Symbol, attrs::Dict = Dict(), content::AbstractVector = c(); kws...) =
  Node{tag}(isempty(kws) ? attrs : merge(attrs, Dict([kws...])),
            content)

Node(tag::Symbol, attrs::Associative, content; kws...) =
  Node(tag, attrs, c(content); kws...)

Node(tag::Symbol, content; kws...) =
  Node(tag, Dict(), content; kws...)

Node(tag::Symbol, content::Node...) = Node(tag, collect(content))

# CSS selector parsing

function cssparse(s)
  trimfirst(s) = s[2:end]
  attrs = Dict()
  id = match(r"#[A-Za-z0-9]+", s)
  id == nothing || (attrs[:id] = trimfirst(id.match))
  classes = matchall(r"\.-?[_a-zA-Z]+[_a-zA-Z0-9-]*", s)
  isempty(classes) || (attrs[:class] = map(trimfirst, classes))
  return attrs
end

Node(tag::Symbol, selector::String, props::Dict, args...; kws...) =
  Node(tag, merge!(cssparse(selector), props), args...; kws...)

Node(tag::Symbol, selector::String, content, args...; kws...) =
  Node(tag, cssparse(selector), content, args...; kws...)

# Rendering

export htmlescape

attrstring(xs::Vector) = join(xs, " ")
attrstring(x) = string(x)
attrstring(d::Dict) = @as _ d map(t->"$(t[1])=\"$(attrstring(t[2]))\"", _) join(_, " ")

htmlescape(s::String) =
    @> s replace(r"&(?!(\w+|\#\d+);)", "&amp;") replace("<", "&lt;") replace(">", "&gt;") replace("\"", "&quot;")

render(io::IO, s::String) = print(io, htmlescape(s))

function render(io::IO, node::Node)
  print(io, "<", tag(node))
  isempty(attrs(node)) || print(io, " ", attrstring(attrs(node)))
  print(io, ">")
  render(io, children(node))

  print(io, "</", tag(node), ">")
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
