/*
	Copyright (C) 2009-2011 DeSmuME team

	This file is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 2 of the License, or
	(at your option) any later version.

	This file is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with the this software.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _COMMANDLINE_H_
#define _COMMANDLINE_H_

#include <string>

//I hate C. we have to forward declare these with more detail than I like
typedef struct _GOptionContext GOptionContext;
typedef struct _GError GError;

//hacky commandline options that i didnt want to route through commonoptions
extern int _commandline_linux_nojoy;

//this class will also eventually try to take over the responsibility of using the args that it handles
//for example: preparing the emulator run by loading the rom, savestate, and/or movie in the correct pattern.
//it should also populate CommonSettings with its initial values

class CommandLine
{
public:
	//actual options: these may move to another sturct
	int load_slot;
	int depth_threshold;
	int debug_console;
	int dsi_mode;
	std::string nds_file;
	std::string play_movie_file;
	std::string record_movie_file;
	int arm9_gdb_port, arm7_gdb_port;
	int start_paused;
	std::string cflash_image;
	std::string cflash_path;
	std::string gbaslot_rom;
	std::string slot1;
	std::string slot1_fat_dir;
#ifndef _MSC_VER
	int disable_sound;
	int disable_limiter;
#endif

	//load up the common commandline options
	void loadCommonOptions();
	
	bool parse(int argc,char **argv);

	//validate the common commandline options
	bool validate();

	//process movie play/record commands
	void process_movieCommands();
	//etc.
	void process_addonCommands();
	bool is_cflash_configured;
	
	//print a little help message for cases when erroneous commandlines are entered
	void errorHelp(const char* binName);

	CommandLine();
	~CommandLine();

	GError *error;
	GOptionContext *ctx;

private:
	char* _play_movie_file;
	char* _record_movie_file;
	char* _cflash_image;
	char* _cflash_path;
	char* _gbaslot_rom;
	char* _bios_arm9, *_bios_arm7;
	int _bios_swi;
	int _spu_advanced;
	int _num_cores;
	int _rigorous_timing;
	int _advanced_timing;
	char* _slot1;
	char *_slot1_fat_dir;
};

#endif
