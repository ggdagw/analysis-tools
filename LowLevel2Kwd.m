function LowLevel2Kwd(data,filename)

%
% script to export a data array from Matlab using the low-level HDF5 interface.
%

%testdata = int16([1 3 5; 2 4 6]);
%data2 = data(144575937:182075937); 
%filename = '101_CH1_excerpt.kwd';

fid = H5F.create(filename,'H5F_ACC_TRUNC','H5P_DEFAULT','H5P_DEFAULT');

%% Create groups
plist = 'H5P_DEFAULT';
gid = H5G.create(fid,'recordings',plist,plist,plist);
gid2 = H5G.create(gid,'0',plist,plist,plist);
gid3 = H5G.create(gid2,'application_data',plist,plist,plist);

% Create attributes
acpl = H5P.create('H5P_ATTRIBUTE_CREATE');

type_id = H5T.copy('H5T_STD_U16LE');
space_id = H5S.create('H5S_SCALAR');
attr_id = H5A.create(fid,'kwik_version',type_id,space_id,acpl);
H5A.write(attr_id,'H5ML_DEFAULT',uint16(2))
H5A.close(attr_id);

type_id = H5T.copy('H5T_STD_U32LE');
space_id = H5S.create('H5S_SCALAR');
attr_id = H5A.create(gid2,'bit_depth',type_id,space_id,acpl);
H5A.write(attr_id,'H5ML_DEFAULT',uint32(16))
%H5A.write(attr_id,'H5ML_DEFAULT',uint32(1))
H5A.close(attr_id);

% name...
dims = 1;
SDIM = 20;
type_id = H5T.copy('H5T_FORTRAN_S1');
H5T.set_strpad(type_id,'H5T_STR_NULLTERM');
H5T.set_size (type_id, SDIM - 1);
memtype = H5T.copy ('H5T_C_S1');
H5T.set_size (memtype, SDIM - 1);
space_id = H5S.create ('H5S_SCALAR');
attr_id = H5A.create (gid2, 'name',type_id,space_id,'H5P_DEFAULT');
H5A.write (attr_id, memtype, 'Sample Recording #0');
H5A.close(attr_id);


type_id = H5T.copy('H5T_IEEE_F32LE');
space_id = H5S.create('H5S_SCALAR');
attr_id = H5A.create(gid2,'sample_rate',type_id,space_id,acpl);
H5A.write(attr_id,'H5ML_DEFAULT',single(30000))
H5A.close(attr_id);

type_id = H5T.copy('H5T_STD_U64LE');
space_id = H5S.create('H5S_SCALAR');
attr_id = H5A.create(gid2,'start_time',type_id,space_id,acpl);
H5A.write(attr_id,'H5ML_DEFAULT',uint64(0))
H5A.close(attr_id);

base_type_id = H5T.copy('H5T_IEEE_F32LE');
space_id = H5S.create('H5S_SCALAR');
dims = [16];
%dims = [1];
h5_dims = fliplr(dims);
array_type_id = H5T.array_create(base_type_id,h5_dims);
attr_id = H5A.create(gid3,'channel_bit_volts',array_type_id,space_id,acpl);
H5A.write(attr_id,'H5ML_DEFAULT',single([0.195 0.195 0.195 0.195 0.195 0.195 0.195 0.195 0.195 0.195 0.195 0.195 0.195 0.195 0.195 0.195]))
%H5A.write(attr_id,'H5ML_DEFAULT',single([0.195]))
H5A.close(attr_id);
H5G.close(gid3);

% create the dataset
type_id = H5T.copy('H5T_STD_I16LE');
dims = size(data);
%space_id = H5S.create_simple(2,fliplr(dims),[]);
space_id = H5S.create_simple(2,dims,[]);
dsetname = 'data';  
datasetID = H5D.create(gid2,dsetname,type_id,space_id,'H5P_DEFAULT');
H5D.write(datasetID,'H5ML_DEFAULT','H5S_ALL','H5S_ALL',...
	  'H5P_DEFAULT',int16(data));

% tidy-up
H5D.close(datasetID);
H5S.close(space_id);
H5T.close(type_id);
H5G.close(gid2);
H5G.close(gid);
H5F.close(fid);

end
