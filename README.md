# Hiccup

```julia
Pkg.add("Hiccup")
```

Hiccup.jl is a super-simple library designed to make making HTML easy in Julia. It's heavily inspired by Clojure's [Hiccup](https://github.com/weavejester/hiccup) DSL.

```julia
julia> using Hiccup

julia> Hiccup.div("#foo.bar", "hi")
<div class="bar" id="foo">hi</div>
```

HTML nodes are stored as the `Node{T}` type which renders itself smartly.

```julia
julia> Node(:img, "#id.class1.class2", Dict(:src=>"http://www.com"))
<img src="http://www.com" id="id" class="class1 class2" />

julia> tag(ans)
:img
```

A bunch of utility functions, with the names of tags, are provided which make this a bit more legible. You can import more with `@tags`:

```julia
julia> @tags img, svg

julia> svg("#id.class1.class2", Dict(:src=>"http://www.com"))
<svg class="class1 class2" src="http://www.com" id="id"></svg>
```

And that's basically it.
