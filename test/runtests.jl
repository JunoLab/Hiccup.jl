using Hiccup
using Base.Test
using Compat

@tags br, link

# hiccup div conflicts with main div, so use this as compromise
ediv = Hiccup.div

@test contains(sprint(Hiccup.render, Node(:img, "#id.class1.class2", @compat Dict(:src=>"http://www.com"))), "class=\"class1 class2\"")

classMatching = ((".section-title", "section-title"),
                 (".test", "test"),
                 (".test1.test2", "test1 test2"),
                 (".-test", "-test"),
                 (".-test1.-test2", "-test1 -test2"),
                 ("#.test", "test"),
                 ("#.test1-hyphen", "test1-hyphen"),
                 ("#.test1-hyphen.test2", "test1-hyphen test2"),
                 ("#id.test1.test2", "test1 test2"),
                 ("#id.test1.-test2", "test1 -test2"),
                 ("#id.test1.-test-2", "test1 -test-2"),
                 ("#id.test-hyphen", "test-hyphen"),
                 ("#id.-test", "-test"),
                 ("#id.-test.test2", "-test test2"),
                 ("#id.-test.-test2", "-test -test2"))
for (in, expected) in classMatching
  @test contains(sprint(Hiccup.render, Hiccup.div(in, "contents")), expected)
end


# tests for void tags
@test string(br()) == "<br />"
@test string(img(".image-test", [])) == "<img class=\"image-test\" />"
@test contains(
  string(link(@compat Dict(:rel => "stylesheet", :href => "test.css"))),
  "/>")
@test_throws ArgumentError img(strong(".test", "test"))

# tests for normal tags
@test string(ediv(ediv(ediv()))) == "<div><div><div></div></div></div>"
