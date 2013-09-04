[~, pc] = system('hostname');pc=strtrim (pc);
savePath='F:\JanResults' ;
global ppath;
ppath='P:\2013\';
wallempath='F:\datasets\walls\';
passfile='P:\xvf';
switch pc
    case 'P1-400'
        addpath(genpath(ppath));
        em=emData.readKNOSSOSconf('T:\CortexConnectomics\shared\cortex\2012-09-28_ex145_07x2\mag1','knossos.conf');
    case 'P1-390'
        addpath(genpath(ppath));
        em=emData.readKNOSSOSconf('F:\datasets\2012-09-28_ex145_07x2\mag1','knossos.conf');
    case 'P1-384'
        addpath(genpath(ppath));
        em=emData.readKNOSSOSconf('Q:\CortexConnectomics\shared\cortex\2012-09-28_ex145_07x2\mag1','knossos.conf');
    case 'T8'
        addpath(genpath(ppath));
        em=emData.readKNOSSOSconf('O:\2012-09-28_ex145_07x2\mag1');
    case 'P1-374'
        addpath(genpath(ppath));
        em=emData.readKNOSSOSconf('T:\CortexConnectomics\shared\cortex\2012-09-28_ex145_07x2\mag1','knossos.conf');
    otherwise
        if strfind(pc,'fermat')
            ppath='/zdata/Jan/2013/';
            addpath(genpath(ppath));
            em=emData.readKNOSSOSconf('/zdata/manuel/data/cortex/2012-09-28_ex145_07x2/mag1','knossos.conf');
            savePath='/zdata/Jan/Results' ;
            wallempath='/zdata/manuel/results/20130610cortexFwdPass/mag1/';
            passfile='~/xvf';
        else
            error('unknow pc');
        end
end
load('autoKLEE_colormap.mat');
load(passfile,'-mat');
setpref('Internet','E_mail',myaddress);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',myaddress);
setpref('Internet','SMTP_Password',char(mypassword-100));

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', ...
    'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');
clear pc
clear dataPath mypassword
