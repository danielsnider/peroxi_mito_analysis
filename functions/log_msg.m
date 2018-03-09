function fun(new_msg)
  new_msg = ['[' char(datetime('now','Format','yyyy-MM-dd HH:mm:ss.SSS')) '] ' new_msg];
  disp(new_msg);
end