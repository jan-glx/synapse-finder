% Modify these two lines to reflect
% your account and password.


jm=findResource;
[~, quequed, runningjobs, ~]=jm. findJob('UserName','jgleixne');
jobs=[runningjobs,quequed];
if numel(jobs)>0
    waitForState(jobs(1),'finished');
    sendmail(myaddress, 'Job finished', evalc('display(jobs(1))'));
end