#implementation
## http://stackoverflow.com/questions/260236/mysql-hashing-function-implementation

class OldPassword
  def self.hash input
    nr = 1345345333
    add = 7
    nr2 = 0x12345671
    tmp = nil;
    input.each_char do |char|
      next if char.empty? || char == "\t"
      byte = char.bytes.first
      nr = nr ^ (((nr & 63) + add) * byte) + ((nr << 8) & 0xFFFFFFFF);
      nr2 += ((nr2 << 8) & 0xFFFFFFFF) ^ nr;
      add += byte
    end
    out_a = nr & ((1 << 31) - 1);
    out_b = nr2 & ((1 << 31) - 1);
    sprintf("%08x%08x", out_a, out_b);
  end
end
