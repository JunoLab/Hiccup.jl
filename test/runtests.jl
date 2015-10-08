using Hiccup
using Base.Test
using Compat

@test beginswith(sprint(Hiccup.render, Node(:img, "#id.class1.class2", [:src=>"http://www.com"])), "<img class=\"class1 class2\"")

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
  @test beginswith(sprint(Hiccup.render, div(in, "contents")), string("<div class=\"", expected, "\""))
end
