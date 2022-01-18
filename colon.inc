%define start_of_dict 0
%macro colon 2

	%ifid %2			
		%2: dq start_of_dict
		%define start_of_dict %2
		
	%else
		%fatal "wrong id"
	%endif
	
	%ifstr %1
		db %1, 0
	%else
		%fatal "wrong key. It should be string"
	%endif
	
%endmacro 
