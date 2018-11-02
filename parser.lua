return function(txt, dm)
  if dm then -- keep dm-only info (but get rid of indicators)
    txt = string.gsub(txt, "*", "")
    return txt
  else
    local open = 0
    while true do
      open = string.find(txt, "*", open+1) -- find start of hidden phrase
      if open then
        local close = string.find(txt, "*", open+1) -- find end of hidden phrase
        if not close then
          txt = string.sub(txt, 1, open-1)
        else
          txt = string.sub(txt, 1, open-1)..string.sub(txt, close+1, -1)
        end
      else
        break
      end
    end
    return txt
  end
end
