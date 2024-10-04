MRP.Factions = {
    [1] = {
        name = "Armée Française",
        flag = "gui/faction/france.png",
        [1] = MRP.SecondREP,
        [2] = MRP.FifthRHC,
        [3] = MRP.FirstREC,
        [3] = MRP.FirstRPIMA,
    },
    [2] = { --Armée rebelle
        name = "Armée rebelle",
        flag = "gui/faction/latvia-nationalist.png",
        {
            name = "5e Régiment National de la Libération",
            insignia = "materials/gui/regiment/latvijai.png",
            whratio = 960 / 720,
            [1] = {
                name = "Recrue soldat",
                short = "",
                appellation = "Recrue ou par le nom",
                bodygroupVal = 0,
                shoulderrank = "null"
            },
            [2] = {
                name = "Soldat",
                short = "SDT",
                appellation = "Soldat ou par le nom",
                bodygroupVal = 1,
                shoulderrank = "materials/null.vmt"
            },
            [3] = {
                name = "Soldat de première classe",
                short = "1CL",
                appellation = "Soldat, première classe ou par le nom",
                bodygroupVal = 2,
                shoulderrank = "materials/null.vmt"
            },
            {
                name = "Caporal",
                short = "CPL",
                appellation = "Caporal",
                bodygroupVal = 3,
                shoulderrank = "materials/null.vmt"
            },
            {
                name = "Caporal-chef",
                short = "CCH",
                appellation = "Caporal-chef",
                bodygroupVal = 4,
                shoulderrank = "materials/null.vmt"
            },
            {
                name = "Caporal-chef de première classe",
                short = "CC1",
                appellation = "Caporal-chef",
                bodygroupVal = 5,
                shoulderrank = "materials/null.vmt"
            },
            {
                name = "Sergent",
                short = "SGT",
                appellation = "Sergent",
                bodygroupVal = 6,
                shoulderrank = "materials/null.vmt"
            },
            {
                name = "Sergent-chef",
                short = "SCH",
                appellation = "Chef",
                bodygroupVal = 7,
                shoulderrank = "materials/null.vmt"
            },
            {
                name = "Adjudant",
                short = "ADJ",
                appellation = "Mon adjudant ou adjudant (féminin)",
                bodygroupVal = 8,
                shoulderrank = "materials/null.vmt"
            },
            {
                name = "Adjudant-chef",
                short = "ADC",
                appellation = "Mon adjudant chef ou adjudant chef (féminin)",
                bodygroupVal = 9,
                shoulderrank = "materials/null.vmt"
            },
            {
                name = "Major",
                short = "MAJ",
                appellation = "Major",
                bodygroupVal = 10,
                shoulderrank = "materials/null.vmt"
            },
            {
                name = "Aspirant",
                short = "ASP",
                appellation = "Mon lieutenant ou lieutenant (féminin)",
                bodygroupVal = 11,
                shoulderrank = "materials/null.vmt"
            },
            {
                name = "Sous-lieutenant",
                short = "SLT",
                appellation = "Mon lieutenant ou lieutenant (féminin)",
                bodygroupVal = 12,
                shoulderrank = "materials/null.vmt"
            },
            {
                name = "Lieutenant",
                short = "LTN",
                appellation = "Mon lieutenant ou lieutenant (féminin)",
                bodygroupVal = 13,
                shoulderrank = "materials/null.vmt"
            },
            {
                name = "Capitaine",
                short = "CNE",
                appellation = "Mon capitaine ou capitaine (féminin)",
                bodygroupVal = 14,
                shoulderrank = "materials/null.vmt"
            },
            {
                name = "Chef de bataillon",
                short = "CBA",
                appellation = "Mon commandant ou commandant (féminin)",
                bodygroupVal = 15,
                shoulderrank = "materials/null.vmt"
            },
            {
                name = "Lieutenant-colonel",
                short = "LCL",
                appellation = "Mon colonel ou colonel (féminin)",
                bodygroupVal = 16,
                shoulderrank = "materials/null.vmt"
            },
            {
                name = "Colonel",
                short = "COL",
                appellation = "Mon colonel ou colonel (féminin)",
                bodygroupVal = 17,
                shoulderrank = "materials/null.vmt"
            }
        }
    }
}
