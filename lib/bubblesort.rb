# arr = [1,2,89,3,4]みたいな形式
def bubble_sort(arr)
  as = arr.size-1
  while as > 1
    (0..as-1).each do |i|
      s = arr[i]
      if arr[i] > arr[i+1]
        arr[i] = arr[i+1]
        arr[i+1] = s
      end
    end
    as-=1
  end
  arr
end