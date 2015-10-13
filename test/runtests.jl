using Hiccup
using Base.Test
using Compat

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
