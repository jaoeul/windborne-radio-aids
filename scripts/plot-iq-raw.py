#!/usr/bin/env python3

import scipy
import plotly.express as px
import pandas as pd

wave = scipy.fromfile('../samples.dat', dtype=scipy.int16)

samples_complex = [complex(i, q) for i, q in zip(wave[::2], wave[1::2])]

samples_i = [float(i) for i in wave[::2]]
samples_q = [float(q) for q in wave[1::2]]

df = pd.DataFrame(list(zip(samples_i, samples_q)), columns = ["I", "Q"])

fig = px.scatter_3d(df, x=df.index, y='I', z='Q')
fig.update_traces(marker_size = 1)

fig.write_html("samples.html")
#fig.show()
