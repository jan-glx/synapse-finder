function [  ] = generateCage(filename, bbox )
%GENERATECAGE Summary of this function goes here
%   Detailed explanation goes here
fid=fopen(filename,'w');
fprintf(fid,'<things>\n');
fprintf(fid,'  <parameters>\n');
fprintf(fid,'    <experiment name="2012-09-28_ex145_07x2"/>\n');
fprintf(fid,'    <scale x="12.0" y="12.0" z="24.0"/>\n');
fprintf(fid,'    <offset x="0" y="0" z="0"/>\n');
fprintf(fid,'    <time ms="1376489908440"/>\n');
fprintf(fid,'    <activeNode id="866"/>\n');
fprintf(fid,'    <editPosition x="1161" y="1502" z="927"/>\n');
fprintf(fid,'  </parameters>\n');
fprintf(fid,'  <thing id="1" color.r="1.0" color.g="0.0" color.b="0.0" color.a="1.0" name="Tree001">\n');
fprintf(fid,'    <nodes>\n');
fprintf(fid,'      <node id="17" radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376480012153"/>\n', bbox([1 2 3]+ [0 0 1]*3));
fprintf(fid,'      <node id="4"  radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376479643741"/>\n', bbox([1 2 3]+ [1 0 1]*3));
fprintf(fid,'      <node id="14" radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376479965692"/>\n', bbox([1 2 3]+ [0 1 0]*3));
fprintf(fid,'      <node id="10" radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376479854787"/>\n', bbox([1 2 3]+ [0 1 1]*3));
fprintf(fid,'      <node id="7"  radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376479764598"/>\n', bbox([1 2 3]+ [0 1 0]*3));
fprintf(fid,'      <node id="18" radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376480045368"/>\n', bbox([1 2 3]+ [0 1 1]*3));
fprintf(fid,'      <node id="12" radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376479874556"/>\n', bbox([1 2 3]+ [1 0 1]*3));
fprintf(fid,'      <node id="1"  radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376479079526"/>\n', bbox([1 2 3]+ [0 0 0]*3));
fprintf(fid,'      <node id="9"  radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376479838548"/>\n', bbox([1 2 3]+ [0 0 1]*3));
fprintf(fid,'      <node id="3"  radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376479606361"/>\n', bbox([1 2 3]+ [1 0 0]*3));
fprintf(fid,'      <node id="5"  radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376479729442"/>\n', bbox([1 2 3]+ [1 1 1]*3));
fprintf(fid,'      <node id="13" radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376479937936"/>\n', bbox([1 2 3]+ [0 1 1]*3));
fprintf(fid,'      <node id="15" radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376479976453"/>\n', bbox([1 2 3]+ [1 0 0]*3));
fprintf(fid,'      <node id="6"  radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376479738778"/>\n', bbox([1 2 3]+ [1 1 0]*3));
fprintf(fid,'      <node id="11" radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376479867578"/>\n', bbox([1 2 3]+ [0 0 1]*3));
fprintf(fid,'      <node id="8"  radius="120.0" x="%u" y="%u" z="%u" inVp="0" inMag="0" time="1376479785239"/>\n', bbox([1 2 3]+ [0 1 1]*3));
fprintf(fid,'    </nodes>\n');
fprintf(fid,'    <edges>\n');
fprintf(fid,'      <edge source="8" target="10"/>\n');
fprintf(fid,'      <edge source="4" target="12"/>\n');
fprintf(fid,'      <edge source="6" target="7"/>\n');
fprintf(fid,'      <edge source="4" target="17"/>\n');
fprintf(fid,'      <edge source="3" target="4"/>\n');
fprintf(fid,'      <edge source="7" target="8"/>\n');
fprintf(fid,'      <edge source="9" target="13"/>\n');
fprintf(fid,'      <edge source="6" target="15"/>\n');
fprintf(fid,'      <edge source="1" target="9"/>\n');
fprintf(fid,'      <edge source="4" target="5"/>\n');
fprintf(fid,'      <edge source="1" target="3"/>\n');
fprintf(fid,'      <edge source="1" target="14"/>\n');
fprintf(fid,'      <edge source="5" target="18"/>\n');
fprintf(fid,'      <edge source="5" target="6"/>\n');
fprintf(fid,'      <edge source="9" target="11"/>\n');
fprintf(fid,'    </edges>\n');
fprintf(fid,'  </thing>\n');
fprintf(fid,'  <branchpoints>\n');
fprintf(fid,'    <branchpoint id="1"/>\n');
fprintf(fid,'  </branchpoints>\n');
fprintf(fid,'  <comments> </comments>\n');
fprintf(fid,'</things>\n');
fclose(fid);
end

