local animateHelper = {
     linear = function(t)
     	return t
     end,
     easeInQuad = function(t)
     	return t*t
     end,
     easeOutQuad = function(t)
     	return t*(2-t)
     end,
     easeInOutQuad = function(t)
         if t<.5 then
             return 2*t*t
         else
             return -1+(4-2*t)*t
         end
     end,
     easeInCubic = function(t)
     	return t*t*t
     end,
     easeOutCubic = function(t)
     	tt = t-1
     	return (tt)*t*t+1
     end,
     easeInOutCubic = function(t)
         if t<.5 then
            return 4*t*t*t
         else
            return (t-1)*(2*t-2)*(2*t-2)+1
         end
     end,
     easeInQuart = function(t)
     	return t*t*t*t
     end,
     easeOutQuart = function(t)
     	local tt = t - 1
     	return 1-(tt)*t*t*t
     end,
     easeInOutQuart = function(t)
     	local tt = t - 1
         if (t<.5 ) then
             return 8*t*t*t*t
         else
             return 1-8*(tt)*t*t*t
         end
     end,
     easeInQuint = function(t)
     	return t*t*t*t*t
     end,
     easeOutQuint = function(t)
     	local tt = t - 1
     	return 1+(tt)*t*t*t*t
     end,
     easeInOutQuint = function(t)
     	local tt = t - 1
         if t<.5 then
             return 16*t*t*t*t*t
         else
             return 1+16*(tt)*t*t*t*t
         end
     end
}

return animateHelper
