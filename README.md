# Introducing the PxIndex gem

    require 'pxindex'

    s =<<EOF
    <?ph schema="entries[title, tags]/entry[title, desc, target, private]"?>
    title: fun

    # a

    apple
    antelope
    asterisk
      configuring
      creating a new dialplan


    # b

    button
    EOF

    pxi = PxIndex.new(s)
    a = pxi.q?('apple').map(&:title)
    #=> ["apple"]

## Resources

* pxindex https://rubygems.org/gems/pxindex

pxindex polyrex index lookup search
