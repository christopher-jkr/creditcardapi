# Double Transposition Cipher
module DoubleTranspositionCipher
  def self.get_gen_att(my_doc, my_rand)
    n_col = Math.sqrt(my_doc.length).round
    my_doc_arr = my_doc.chars.each_slice(n_col).to_a
    n_row = my_doc_arr.length
    row_s = (0...n_row).to_a.shuffle(random: my_rand)
    col_s = (0...n_col).to_a.shuffle(random: my_rand)
    [row_s, col_s, n_col, n_row, my_doc_arr]
  end

  def self.pad_array(doc_arr, n_col)
    (0...n_col).to_a.each_index do |idx|
      doc_arr.last[idx] = 0.chr if doc_arr.last[idx].nil?
    end
  end

  def self.row_shift(doc_arr, row, row_s)
    doc_arr_r = [[]]
    row.each do |idx|
      doc_arr_r[row[idx]] = doc_arr[row_s[idx]]
    end
    doc_arr_r
  end

  def self.col_shift(doc_arr, col_s)
    doc_arr_c = []
    lth = col_s.length
    doc_arr.each_index do |idx|
      mod, div = idx % lth, idx / lth
      b = div * lth + col_s[mod]
      doc_arr_c[b] = doc_arr[idx]
    end
    doc_arr_c
  end

  def self.encrypt(document, key)
    document = document.to_s
    gen_att = get_gen_att(document, Random.new(key))
    row_s, col_s, n_col, n_row, my_doc_arr = *gen_att
    pad_array(my_doc_arr, n_col)
    my_doc_arr = row_shift(my_doc_arr, (0...n_row).to_a, row_s).flatten
    col_shift(my_doc_arr, col_s).join
  end

  def self.col_dec_shift(doc_arr, col_s)
    doc_arr_c = []
    lth = col_s.length
    doc_arr.each_index do |idx|
      mod, div = idx % lth, idx / lth
      b = div * lth + col_s[mod]
      doc_arr_c[idx] = doc_arr[b]
    end
    doc_arr_c
  end

  def self.decrypt(document, key)
    gen_att = get_gen_att(document, Random.new(key))
    row_s, col_s, n_col, n_row, my_doc_arr = *gen_att
    my_doc_arr = my_doc_arr.flatten
    my_doc_arr = col_dec_shift(my_doc_arr, col_s)
    my_doc_arr = my_doc_arr.each_slice(n_col).to_a
    row_shift(my_doc_arr, row_s, (0...n_row).to_a).join.tr(0.chr, '')
  end
end
