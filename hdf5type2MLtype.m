function [ typ ] = hdf5type2MLtype( typ5 )
%HDF5TYPE2MLTYPE Summary of this function goes here
%   Detailed explanation goes here
    switch (typ5.Type)
        case 'H5T_STD_U8LE'
            typ='utf8';
        case 'H5T_IEEE_F32LE'
            typ='float';    
        otherwise
            error('unknown type!');
    end
end

