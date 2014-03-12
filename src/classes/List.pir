.namespace ['List']

.sub 'onload' :anon :load :init
    .local pmc meta
    meta = get_hll_global ['Object'], '!META'
    meta.'new_class'('List', 'parent' => 'parrot;ResizablePMCArray Object')
.end
