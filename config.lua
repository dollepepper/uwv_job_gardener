Config = {}

Config.JobName = 'uwv_gardener'
Config.JobLabel = 'UWV Gardener'

Config.Payment = {
    lawnmower = 50,
    leafcollector = 30,
    weedraker = 40,
}

Config.Locations = {
    jobStart = {
        coords = vector3(-1349.103271, 142.430771, 56.256470),
        blip = {
            sprite = 1,
            color = 2,
            scale = 0.8,
            label = 'UWV Gardener Job',
        },
    },
}

Config.LawnMower = {
    spawnPoint = vector4(-1344.303345, 131.604401, 56.222656, 206.929138),

    lawnAreas = {
        {
            center = vector3(-1338.000000, 122.808792, 56.610229),
            radius = 15.0,
            name = 'Central Park Lawn',
        },
        {
            center = vector3(-1315.239502, 134.360443, 57.907715),
            radius = 12.0,
            name = 'Side Garden',
        },
        {
            center = vector3(-1332.962646, 115.595604, 56.576538),
            radius = 12.0,
            name = 'Side Garden 2',
        },
        {
            center = vector3(-1292.096680, 125.815384, 57.301147),
            radius = 10.0,
            name = 'Front Yard',
        },
        {
            center = vector3(-1287.164795, 111.257141, 56.610229),
            radius = 10.0,
            name = 'Front Yard 2',
        },
        {
            center = vector3(-1269.731812, 132.263733, 58.194092),
            radius = 10.0,
            name = 'Front Yard 3',
        },
        {
            center = vector3(-1271.432983, 158.848358, 58.783936),
            radius = 10.0,
            name = 'Front Yard 4',
        },
        {
            center = vector3(-1283.076904, 166.180222, 59.019775),
            radius = 10.0,
            name = 'Front Yard 5',
        },
        {
            center = vector3(-1276.285767, 181.107697, 60.249756),
            radius = 10.0,
            name = 'Front Yard 6',
        },
        {
            center = vector3(-1244.083496, 180.685715, 62.659302),
            radius = 10.0,
            name = 'Front Yard 7',
        },
    }
}

Config.LeafCollector = {
    leafPiles = {
        vector3(-1282.707642, 133.463745, 57.789795),
        vector3(-1271.643921, 117.441757, 57.250488),
        vector3(-1280.334106, 97.767036, 55.161133),
        vector3(-1271.432983, 158.848358, 58.783936),
        vector3(-1283.076904, 166.180222, 59.019775),
        vector3(-1276.285767, 181.107697, 60.249756),
        vector3(-1288.523071, 78.408791, 54.891602),
        vector3(-1305.705444, 69.626373, 54.082764),
        vector3(-1290.065918, 62.070332, 52.903320),
        vector3(-1261.503296, 71.643959, 52.431519),
        vector3(-1254.039551, 83.604401, 53.476196),
    },
}

Config.WeedRaker = {
    weedPiles = {
        vector3(-1337.261597, 142.470337, 57.183105),
        vector3(-1333.261597, 142.470337, 57.183105),
        vector3(-1271.512085, 123.243958, 57.570679),
        vector3(-1267.028564, 140.848358, 58.497437),
        vector3(-1234.773682, 132.145050, 58.194092),
        vector3(-1247.287964, 112.523079, 56.947266),
        vector3(-1276.628540, 91.925278, 54.504028),
        vector3(-1285.793457, 86.452751, 54.891602),
        vector3(-1287.243896, 68.202202, 54.065918),
        vector3(-1280.610962, 54.659340, 51.471069),

    },
}

Config.Blips = {
    lawnmower = {
        sprite = 1,
        color = 2,
        scale = 0.6,
        label = 'Lawn Mower Job',
    },
    leafcollector = {
        sprite = 1,
        color = 3,
        scale = 0.6,
        label = 'Leaf Collector Job',
    },
    weedraker = {
        sprite = 1,
        color = 4,
        scale = 0.6,
        label = 'Weed Raker Job',
    },
}

Config.Cooldowns = {
    lawnmower = 30,
    leafcollector = 30,
    weedraker = 30,
}

Config.TaskTime = {
    leafcollector = 10000,
    weedraker = 10000,
}
