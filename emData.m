classdef emData < matlab.mixin.Copyable
    %EMDATA Summary of this class goes here
    %   Detailed explanation goes here
    properties (Access = private)
        typ;
    end
     properties (GetAccess = private, Constant)
        TYP_KNOSSOS=1;
        TYP_HDF5=2;
    end
    properties
        scale;
        scale_unit;
        expName;
        dataPath;
        boundary;
        dim;
        magnification;
        classT;
        overlap=0;
    end

    methods (Static)
        function obj = readKNOSSOSconf(KNOSSOS_mainpath,KNOSSOS_Conf_Filename,classTT)
            obj=emData();
            if(~exist('KNOSSOS_Conf_Filename','var')||isempty(KNOSSOS_Conf_Filename))                
                KNOSSOS_Conf_Filename='knossos.conf';
            end
            [ ~, KNOSSOS_experiment_name, KNOSSOS_boundary_x,...
                KNOSSOS_boundary_y, KNOSSOS_boundary_z, KNOSSOS_scale_x, ...
                KNOSSOS_scale_y, KNOSSOS_scale_z,KNOSSOS_mag]...
                = KNOSSOS_readKconfFile( KNOSSOS_mainpath,KNOSSOS_Conf_Filename );            
            obj.expName=strsplit(KNOSSOS_experiment_name{1}{1},'_');
            obj.expName=strjoin(obj.expName(1:end-1),'_');
            obj.scale= [KNOSSOS_scale_x{1} KNOSSOS_scale_y{1} KNOSSOS_scale_z{1}];
            obj.scale_unit='(nm)(lixel)^-1';
            obj.magnification=KNOSSOS_mag{1};
            obj.boundary=[KNOSSOS_boundary_x{1} KNOSSOS_boundary_y{1} KNOSSOS_boundary_z{1}];
            obj.dataPath=KNOSSOS_mainpath;
            if ~exist('classTT','var')||isempty(classTT)
                obj.classT='uint8';
            else
                obj.classT=classTT;
            end
            obj.dim=1;            
            obj.typ=emData.TYP_KNOSSOS;
        end
        function obj = readHDF5att(dataPath,mag)
            if(~exist('mag','var'))                
                mag=1;
            end
            %% atributes
            obj=emData();
            obj.dataPath=dataPath;
            obj.expName=h5readatt(obj.dataPath,'/','experiment name');
            if iscell(obj.expName)
                obj.expName=obj.expName{1}(obj.expName{1}>0);
            else
                obj.expName=obj.expName(obj.expName>0);
            end
            obj.boundary=h5readatt(obj.dataPath,'/raw','boundary');
            obj.boundary=obj.boundary(end:-1:1).';
            obj.scale=h5readatt(obj.dataPath,'/raw','scale');
            obj.scale=obj.scale(end:-1:1);
            obj.scale_unit=h5readatt(obj.dataPath,'/raw','scale_unit');
            obj.magnification=mag;
            obj.magnification=h5readatt(obj.dataPath,obj.hdf5datasetpath,'magnification');
            info=h5info(obj.dataPath,obj.hdf5datasetpath);
            obj.classT=hdf5type2MLtype(info.Datatype);
            obj.dim=info.Dataspace.Size(4:end);
            if isempty(obj.dim)
                obj.dim=1;
            end
            obj.typ=emData.TYP_HDF5;
        end   
    end
    methods
        function writeKNOSSOSconf(obj)
            if ~exist(obj.dataPath,'dir');
                mkdir(obj.dataPath);
            end
            writeKnossosConf(obj.dataPath, obj.fullName, obj.boundary, obj.scale, obj.magnification);
            obj.typ=emData.TYP_KNOSSOS;
        end
        function writeHDF5file(obj)
            folder=fileparts(obj.dataPath);
            if ~exist(folder,'dir');
                mkdir(folder);
            end
            h5create(obj.dataPath,obj.hdf5datasetpath,[obj.boundary obj.dimdim],'ChunkSize',[64,64,32, obj.dim(1:find(obj.dim-1>0))], 'Datatype',obj.classT,'Deflate',9,'FillValue',cast(0,obj.classT));
            obj.typ=emData.TYP_HDF5;
            obj.writeHDF5att();
        end
        function dim=dimdim(obj)
            dim=obj.dim(1:find(obj.dim-1>0));
        end
        
        function writeHDF5att(obj)
            %% atributes
            h5writeatt(obj.dataPath,'/','experiment name',obj.expName);
            h5writeatt(obj.dataPath,'/raw','boundary',obj.boundary(end:-1:1));
            h5writeatt(obj.dataPath,'/raw','scale',obj.scale(end:-1:1));
            h5writeatt(obj.dataPath,'/raw','scale_unit','(nm)(lixel)^-1');
            h5writeatt(obj.dataPath,obj.hdf5datasetpath,'magnification',obj.magnification);  
            obj.typ=emData.TYP_HDF5;
        end
        function y=readRoi(obj,roi)
            switch obj.typ
                case emData.TYP_HDF5
                    start=[roi(:,1); ones(find(obj.dim-1>0),1)];
                    count=[diff(roi.')+1, obj.dim(1:find(obj.dim-1>0)).'];
                    y=h5read (obj.dataPath,obj.hdf5datasetpath,start.',count);
                case emData.TYP_KNOSSOS
                    y=readKnossosRoi(obj.dataPath, obj.fullName,roi,obj.classT,[128 128 128 obj.dimdim],obj.overlap);
                otherwise
                    error('unimplemented type!');
            end
            if (~any(y(:)))
                warning('nuthing read')
            end
        end
        function x=readRoiNm(obj,roi,varargin)
            x=obj.readRoi(obj.nm2voxel(roi).',varargin{:});
        end
        function writeRoi(obj,data,roi)
            
            start=[roi(1,:), ones(1,find(obj.dim-1>0,1,'last'))];
            switch obj.typ
                case emData.TYP_HDF5
                    count=[diff(roi)+1, obj.dim(1:find(obj.dim-1>0))];
                    h5write(obj.dataPath,obj.hdf5datasetpath,cast(data,obj.classT),start,count);
                case emData.TYP_KNOSSOS
                     writeKnossosRoi( obj.dataPath,  obj.fullName, start, data, obj.classT,[128 128 128 obj.dimdim]);
                otherwise
                    error('unimplemented type!');
            end
        end
        function datasetpath=hdf5datasetpath(obj)
             datasetpath=sprintf('/raw/mag%i',obj.mag);
        end
        function y = voxel2nm(this,x)
            y=bsxfun(@times,x,this.scale);
        end
        function x = nm2voxel(this,y)
            x=bsxfun(@rdivide,y,this.scale);
        end
        function y = idx2nm(this,x)
            y=this.voxel2nm(x-1);
        end
        function x = nm2idx(this,y)
            x=1+round(this.nm2voxel(y));
        end
        function name = dataName(obj)
            name=obj.expName;
        end
        function name = fullName(obj)
            name=sprintf([obj.expName '_mag%i'],obj.magnification);
        end
        function mag = mag(obj)
            mag=obj.magnification;
        end
        function anisotropie = anisotropie(obj)
            anisotropie=obj.scale;
        end
        
        function copy2hdf5(em,filename)
            %%em=emData();
            %%em.readKNOSSOSconf('I:\CortexConnectomics\shared\cortex\2012-09-28_ex145_07x2\mag1','knossos.conf');
            %% filename='F:\datasets\2012-09-28_ex145_07x2.h5';
            %% create
            emOut=em.copy();
            emOut.dataPath=filename;
            emOut.writeHDF5file();
                        
            %% write
            kl_bbox=[[1 1 1].',siz.'];
            kl_parfolder=em.dataPath;
            kl_fileprefix=em.expName;
            kl_filesuffix = '';
            ending = 'raw';
            
            kl_bbox_size = kl_bbox(:,2)' - kl_bbox(:,1)' + [1 1 1];
            kl_bbox_cubeind = [floor(( kl_bbox(:,1) - 1) / 128 ) ceil( kl_bbox(:,2) / 128 ) - 1];
            
            n=prod(diff(kl_bbox_cubeind.')+1);i=0;startt=tic;
            % Read every cube touched with readKnossosCube and write it in the right
            % place of the kl_roi matrix
            for kl_cx = kl_bbox_cubeind(1,1) : kl_bbox_cubeind(1,2)
                for kl_cy = kl_bbox_cubeind(2,1) : kl_bbox_cubeind(2,2)
                    for kl_cz = kl_bbox_cubeind(3,1) : kl_bbox_cubeind(3,2)
                        
                        kl_thiscube_coords = [[kl_cx, kl_cy, kl_cz]', [kl_cx, kl_cy, kl_cz]' + 1] * 128;
                        kl_thiscube_coords(:,1) = kl_thiscube_coords(:,1) + 1;
                        
                        kl_validbbox = [max( kl_thiscube_coords(:,1), kl_bbox(:,1) ),...
                            min( kl_thiscube_coords(:,2), kl_bbox(:,2) )];
                        
                        kl_validbbox_cube = kl_validbbox - repmat( kl_thiscube_coords(:,1), [1 2] ) + 1;
                        kl_validbbox_roi = kl_validbbox - repmat( kl_bbox(:,1), [1 2] ) + 1;
                        
                        kl_cube = readKnossosCube( kl_parfolder, kl_fileprefix, [kl_cx, kl_cy, kl_cz], [classT '=>' classT], kl_filesuffix, ending );
                        data=kl_cube( kl_validbbox_cube(1,1) : kl_validbbox_cube(1,2),...
                            kl_validbbox_cube(2,1) : kl_validbbox_cube(2,2),...
                            kl_validbbox_cube(3,1) : kl_validbbox_cube(3,2) );                        
                        emOut.writeRoi(data,kl_validbbox_roi);
                        i=i+1;
                    end
                    fprintf('wrote cube %i of %i. estimated time remaining: %s \n',i,n,  secs2hms(toc(startt)*(n/i-1)));
                end
            end
            
        end
    end
end

