.namespace ['Hash']

.sub 'onload' :anon :load :init
    .local pmc meta
    meta = get_hll_global ['Object'], '!META'
    meta.'new_class'('Hash', 'parent' => 'parrot;Hash Object')
.end
